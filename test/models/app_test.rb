require 'test_helper'

class AppTest < ActiveSupport::TestCase
  
  setup do
    @app = App.new
    @app.name = randstr
    @app.website = "https://#{randstr special: false}.com"
  end

  test "should create app" do
    assert_difference "App.count", +1 do
      @app.save
    end
    assert @app.key.length >= 40, "Didn't generate key of at least length 40"
    assert @app.secret.length >= 40, "Didn't generate secret of at least length 40"
  end
  
  test "should not create without name" do
    @app.name = nil
    assert_no_difference "App.count" do
      @app.save
    end
  end
  
  test "should not create without website" do
    @app.website = nil
    assert_no_difference "App.count" do
      @app.save
    end
  end
  
  %w[website support_url callback_url author_url].each do |x|
    test "should verify #{x} format" do
      @app.send("#{x}=", 'not-a-website')
      assert_no_difference "App.count" do
        @app.save
      end
    end
  end
  
  test "should validate uniqueness of name" do
    @app.name = App.first.name
    assert_no_difference "App.count" do
      @app.save
    end
  end
  
  test "should get apps not added by user" do
    User.all.each do |user|
      not_added = App.not_added_by(user)
      
      # verify that all in "not_added" aren't added
      not_added.each do |app|
        assert_not_includes user.get_apps(:added).map(&:name), app.name,
          "App #{app} was added by user #{user.email}"
      end
      
      # verify that all not in "not_added" are added
      App.all.each do |app|
        unless app.in?(not_added)
          assert_includes user.get_apps(:added).map(&:name), app.name,
            "App #{app} was not added by user #{user.email}"
        end
      end
    end
  end

end