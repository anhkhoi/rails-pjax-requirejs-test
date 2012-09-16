require "vcr"

VCR.configure do |c|
  c.cassette_library_dir = "features/vcr_cassettes"
  c.hook_into :webmock
  c.allow_http_connections_when_no_cassette = true
  c.ignore_localhost = true
end

VCR.cucumber_tags do |t|
  t.tag "@remote", use_scenario_name: true, allow_playback_repeats: true
end