require_relative './test_helper'
require 'quakes/record_parser'

module Quakes
  class TestRecordParser < Minitest::Test
    class Dummy
      class << self
        include RecordParser
        public :extract_record
      end
    end

    def test_finds_record_alone
      msg = %q({"type":"Feature","properties":{"mag":1,"place":"69km SSW of Kobuk, Alaska","time":1531685263575,"updated":1531685447713,"tz":-540,"url":"https://earthquake.usgs.gov/earthquakes/eventpage/ak19872213","detail":"https://earthquake.usgs.gov/earthquakes/feed/v1.0/detail/ak19872213.geojson","felt":null,"cdi":null,"mmi":null,"alert":null,"status":"automatic","tsunami":0,"sig":15,"net":"ak","code":"19872213","ids":",ak19872213,","sources":",ak,","types":",geoserve,origin,","nst":null,"dmin":null,"rms":0.62,"gap":null,"magType":"ml","type":"earthquake","title":"M 1.0 - 69km SSW of Kobuk, Alaska"},"geometry":{"type":"Point","coordinates":[-157.5692,66.3434,9.9]},"id":"ak19872213"},)

      out = %q({"mag":1,"place":"69km SSW of Kobuk, Alaska","time":1531685263575,"updated":1531685447713,"tz":-540,"url":"https://earthquake.usgs.gov/earthquakes/eventpage/ak19872213","detail":"https://earthquake.usgs.gov/earthquakes/feed/v1.0/detail/ak19872213.geojson","felt":null,"cdi":null,"mmi":null,"alert":null,"status":"automatic","tsunami":0,"sig":15,"net":"ak","code":"19872213","ids":",ak19872213,","sources":",ak,","types":",geoserve,origin,","nst":null,"dmin":null,"rms":0.62,"gap":null,"magType":"ml","type":"earthquake","title":"M 1.0 - 69km SSW of Kobuk, Alaska"})

      assert_equal out, Dummy.extract_record(msg)
    end

    def test_finds_record_in_the_middle
      msg = %q({"type":"FeatureCollection","metadata":{"generated":1531686089000,"url":"https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_month.geojson","title":"USGS All Earthquakes, Past Month","status":200,"api":"1.5.8","count":26495},"features":[{"type":"Feature","properties":{"mag":2.1,"place":"7km WSW of Volcano, Hawaii","time":1531685578910,"updated":1531686008990,"tz":-600,"url":"https://earthquake.usgs.gov/earthquakes/eventpage/hv70427877","detail":"https://earthquake.usgs.gov/earthquakes/feed/v1.0/detail/hv70427877.geojson","felt":1,"cdi":2.5,"mmi":null,"alert":null,"status":"automatic","tsunami":0,"sig":68,"net":"hv","code":"70427877","ids":",hv70427877,","sources":",hv,","types":",dyfi,geoserve,origin,phase-data,","nst":21,"dmin":0.007887,"rms":0.2,"gap":65,"magType":"ml","type":"earthquake","title":"M 2.1 - 7km WSW of Volcano, Hawaii"},"geometry":{"type":"Point","coordinates":[-155.2971649,19.3991661,0.29]},"id":"hv70427877"},
{"type":"Feature","properties":{"mag":1,"place":"69km SSW of Kobuk, Alaska","time":1531685263575,)

      out = %q({"mag":2.1,"place":"7km WSW of Volcano, Hawaii","time":1531685578910,"updated":1531686008990,"tz":-600,"url":"https://earthquake.usgs.gov/earthquakes/eventpage/hv70427877","detail":"https://earthquake.usgs.gov/earthquakes/feed/v1.0/detail/hv70427877.geojson","felt":1,"cdi":2.5,"mmi":null,"alert":null,"status":"automatic","tsunami":0,"sig":68,"net":"hv","code":"70427877","ids":",hv70427877,","sources":",hv,","types":",dyfi,geoserve,origin,phase-data,","nst":21,"dmin":0.007887,"rms":0.2,"gap":65,"magType":"ml","type":"earthquake","title":"M 2.1 - 7km WSW of Volcano, Hawaii"})

      assert_equal out, Dummy.extract_record(msg)
    end

    def test_finds_record_at_bottom
      msg = %q({"type":"Feature","properties":{"mag":2.83,"place":"5km WSW of Volcano, Hawaii","time":1529094089920,"updated":1529123046870,"tz":-600,"url":"https://earthquake.usgs.gov/earthquakes/eventpage/hv70271851","detail":"https://earthquake.usgs.gov/earthquakes/feed/v1.0/detail/hv70271851.geojson","felt":null,"cdi":null,"mmi":null,"alert":null,"status":"automatic","tsunami":0,"sig":123,"net":"hv","code":"70271851","ids":",hv70271851,","sources":",hv,","types":",geoserve,origin,phase-data,","nst":43,"dmin":0.006591,"rms":0.26,"gap":25,"magType":"ml","type":"earthquake","title":"M 2.8 - 5km WSW of Volcano, Hawaii"},"geometry":{"type":"Point","coordinates":[-155.2861633,19.4113331,0.06]},"id":"hv70271851"}],"bbox":[-179.9734,-63.7018,-3.66,179.9693,79.2312,646.7]})

      out = %q({"mag":2.83,"place":"5km WSW of Volcano, Hawaii","time":1529094089920,"updated":1529123046870,"tz":-600,"url":"https://earthquake.usgs.gov/earthquakes/eventpage/hv70271851","detail":"https://earthquake.usgs.gov/earthquakes/feed/v1.0/detail/hv70271851.geojson","felt":null,"cdi":null,"mmi":null,"alert":null,"status":"automatic","tsunami":0,"sig":123,"net":"hv","code":"70271851","ids":",hv70271851,","sources":",hv,","types":",geoserve,origin,phase-data,","nst":43,"dmin":0.006591,"rms":0.26,"gap":25,"magType":"ml","type":"earthquake","title":"M 2.8 - 5km WSW of Volcano, Hawaii"})

      assert_equal out, Dummy.extract_record(msg)
    end

    def test_returns_nil_if_not_found
      assert_nil Dummy.extract_record('')
      assert_nil Dummy.extract_record('hello world')
      assert_nil Dummy.extract_record('{"type":"Feature","properties":{"mag":1.0}}}')
      assert_nil Dummy.extract_record('{"type":"Test","properties:{"mag":1.0},}')
    end
  end
end
