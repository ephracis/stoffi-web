require 'test_helper'

class SearchControllerTest < ActionController::TestCase
  def setup
    @artists = 
    {
      'results' =>
      {
        'opensearch:totalResults' => 3,
        'artistmatches' => { 'artist' =>
          [
            {
              'name' => 'Bob Marley',
              'listeners' => '123',
              'url' => 'http://foo.com/artist/bob_marley',
              'image' => [
                { '#text' => 'http://img.com/b_s.jpg', 'size' => 'small' },
                { '#text' => 'http://img.com/b_m.jpg', 'size' => 'medium' },
                { '#text' => 'http://img.com/b_l.jpg', 'size' => 'large' },
              ]
            },
            {
              'name' => 'Damian Marley',
              'listeners' => '12',
              'url' => 'http://foo.com/artist/damian_marley',
              'image' => [
                { '#text' => 'http://img.com/d_s.jpg', 'size' => 'small' },
                { '#text' => 'http://img.com/d_m.jpg', 'size' => 'medium' },
                { '#text' => 'http://img.com/d_l.jpg', 'size' => 'large' },
              ]
            },
            {
              'name' => 'Stephen Marley',
              'listeners' => '23',
              'url' => 'http://foo.com/artist/stephen_marley',
              'image' => [
                { '#text' => 'http://img.com/s_s.jpg', 'size' => 'small' },
                { '#text' => 'http://img.com/s_m.jpg', 'size' => 'medium' },
                { '#text' => 'http://img.com/s_l.jpg', 'size' => 'large' },
              ]
            }
          ]
        }
      }
    }
    super
  end 

  test "should get index" do
    SearchController.any_instance.expects(:origin_position).returns({ longitude: 123, latitude: 123 })
    get :index
    assert_response :success
  end

  test "should get suggest" do
    get :suggestions, format: :json
    assert_response :success
  end
  
  test "should get javascript" do
    #remove_request_stub @sunspot_stub rescue nil
    stub_request(:post, %r{http://localhost:8981/solr/test/.*})
      .with(body: /.*/, headers: { 'Content-Type' => /.*/ })
      .to_return(
        status: 200,
        body: "{'responseHeader'=>{'status'=>0,'QTime'=>69},'response'=>{"\
"'numFound'=>19,'start'=>0,'docs'=>[{'id'=>'Media::Album 213998861',"\
"'_version_'=>'1538259973136449536'},{'id'=>'Media::Artist 666325012',"\
"'_version_'=>'1538259973163712512'},{'id'=>'Media::Artist 1041224392',"\
"'_version_'=>'1538259973195169792'},{'id'=>'Media::Genre 212674682',"\
"'_version_'=>'1538259977648472064'},{'id'=>'Media::Genre 357231802',"\
"'_version_'=>'1538259976215068672'},{'id'=>'Media::Playlist 922717355',"\
"'_version_'=>'1538259986317049856'},{'id'=>'Media::Event 92075913',"\
"'_version_'=>'1538259982117502976'},{'id'=>'Media::Playlist 926803614',"\
"'_version_'=>'1538259985935368192'},{'id'=>'Media::Artist 327254663',"\
"'_version_'=>'1538259985795907584'},{'id'=>'Media::Song 601625396',"\
"'_version_'=>'1538259986460704768'},{'id'=>'Media::Playlist 941884569',"\
"'_version_'=>'1538259985113284608'},{'id'=>'Media::Playlist 941884570',"\
"'_version_'=>'1538259984014376960'},{'id'=>'Media::Song 836826700',"\
"'_version_'=>'1538259988105920512'},{'id'=>'Media::Album 1023350213',"\
"'_version_'=>'1538259988836777984'},{'id'=>'Media::Event 853373433',"\
"'_version_'=>'1538259988948975616'},{'id'=>'Media::Artist 1041224394',"\
"'_version_'=>'1538259989002452992'},{'id'=>'Media::Artist 1041224395',"\
"'_version_'=>'1538259989028667392'},{'id'=>'Media::Song 910347896',"\
"'_version_'=>'1538259989108359168'},{'id'=>'Media::Artist 1041224393',"\
"'_version_'=>'1538259989136670720'}]}}"
      )
    xhr :get, :index, format: :js
    assert_response :success
  end
  
  # test "should get from backends" do
  #   backend_stub = stub_request(:any, /.*ws.audioscrobbler.com.*method=artist\.search.*/).
  #     to_return(:body => @artists.to_json, :status => 200).times(1)
  #   s = searches(:bob_marley)
  #   searches(:Bob_Marley).update_attribute(:updated_at, 2.years.ago)
  #   get :fetch, { format: :html, id: s.id }
  #   assert_response :success
  #   assert_not_nil assigns(:results)
  #   remove_request_stub(backend_stub)
  # end

end
