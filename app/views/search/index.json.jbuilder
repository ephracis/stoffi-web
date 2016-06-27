json.extract! @results,
              :total_sources,
              :total_hits,
              :total_pages,
              :first_page,
              :last_page,
              :previous_page,
              :next_page,
              :out_of_bounds,
              :offset

json.hits @results[:hits] do |hit|
  if hit.is_a?(Media::Song)
    json.partial! 'media/songs/song', song: hit
  else
    json.partial! hit
  end
end
