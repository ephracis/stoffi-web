# frozen_string_literal: true
class Crawler
  def initialize
    raise 'Crawler already running' if Crawler.running?
    logger 'Starting crawler'
    # Thread.new {
    # begin
    setup
    work
    # rescue
    #   clean
    # end
    # }
  end

  def self.stop
    unless running?
      logger 'No crawler running'
      return
    end

    begin
      File.delete pid_file
      logger 'Crawler has been stopped'
    rescue StandardError
      logger 'Could not stop crawler'
      logger "You have to manually remove the file #{PID_FILE}"
    end
  end

  def self.status
    if running? && File.exist?(state_file)
      state = YAML.load_file state_file
      {
        running: true,
        processed: state[:processed].size,
        runtime: Time.current - state[:start],
        current_query: state[:current_query],
        queue: state[:queue].size
      }
    else
      { running: false }
    end
  end

  # private

  def self.running?
    File.exist? pid_file
  end

  def setup
    @state = {
      start: Time.current,
      current_query: nil,
      queue: [],
      processed: []
    }
    @last_stop_check = Time.current

    File.open(Crawler.pid_file, 'w') { |f| f.write(Process.pid) }
    @state = YAML.load_file Crawler.state_file if File.exist? Crawler.state_file

    desired_size = 50
    @state[:queue].reverse! if @state[:queue].size < desired_size
    popular = Search.where(['created_at > ?', 7.days.ago]).group(:query)
                    .order('count_id desc').count(:id).first(desired_size)
    @state[:queue] += popular.map { |x| x[0] }

    [Artist, Song, Album].each do |resource|
      if @state[:queue].size < desired_size
        @state[:queue] += resource.top.limit(desired_size).map(&:display).uniq
      end
    end

    @state[:queue].reject!(&:blank?).reverse!

    save
  end

  def work
    sources = Search.sources.join '|'
    categories = Search.categories.join '|'
    logger 'Starting the work'
    logger "Queue length: #{@state[:queue].length}"

    until @state[:queue].empty?
      @state[:current_query] = @state[:queue].pop

      logger "Processing query: #{@state[:current_query]}"

      hits = Search.search_backends @state[:current_query], categories, sources
      Search.save_hits(hits)

      # fill queue with more queries
      hits.each do |h|
        begin
          [:name, :title].each do |k|
            next unless h.key? k
            h[k].split.map(&:strip).reject(&:blank?).uniq.each do |q|
              @state[:queue].push(q) if new? q
            end
          end
        rescue StandardError
          logger 'Could not add query to queue'
        end
      end

      @state[:processed] << @state[:current_query]

      # save the current state
      save

      # check if we should stop
      break if stop?
    end

    # clean up before we die
    clean
  end

  def clean
    File.delete Crawler.pid_file
  rescue
    nil
  end

  def stop?
    return false unless File.exist? Crawler.pid_file
    pid = File.read Crawler.pid_file
    pid.to_i != Process.pid
  end

  def save
    logger 'saving state'
    File.open(Crawler.state_file, 'w') { |f| f.write @state.to_yaml }
  end

  def processed?(query)
    @state[:processed].any? { |s| s.casecmp(query) == 0 }
  rescue
    false
  end

  def queued?(query)
    @state[:queue].any? { |s| s.casecmp(query) == 0 }
  rescue
    false
  end

  def new?(query)
    !(queued?(query) || processed?(query))
  end

  PID_FILE = 'crawler.pid'
  STATE_FILE = 'state.yml'

  def self.base_path
    File.dirname __FILE__
  end

  def self.pid_file
    File.join base_path, PID_FILE
  end

  def self.state_file
    File.join base_path, STATE_FILE
  end
end
