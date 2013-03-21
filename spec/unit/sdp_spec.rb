require 'spec_helper'
require 'sdp'

SDP_TEXT =<<EOF
v=0
o=jdoe 2890844526 2890842807 IN IP4 10.47.16.5
s=SDP Seminar
i=A Seminar on the session description protocol
u=http://www.example.com/seminars/sdp.pdf
e=j.doe@example.com (Jane Doe)
p=+1 617 555-6011
c=IN IP4 224.2.17.12/127
b=CT:1000
t=2873397496 2873404696
r=604800 3600 0 90000
z=2882844526 -1h
k=clear:password
a=recvonly
a=type:test
m=audio 49170 RTP/AVP 0
m=video 51372 RTP/AVP 99
a=rtpmap:99 h263-1998/90000
EOF

describe SDP do
  describe "VERSION" do
    specify { SDP.const_get('VERSION').should eql '0.2.9' }
  end

  it "raises when parsing malformed SDP text" do
    expect { SDP.parse("pants") }.to raise_error SDP::ParseError
  end
  
  context "parses SDP text into a Hash" do
    before do
      begin
        @parsed_sdp = SDP.parse SDP_TEXT
      rescue Parslet::ParseFailed => error
        puts error, parser.root.error_tree
      end
    end

    it "has a version number of 0" do
      @parsed_sdp.session_description.protocol_version.should == 0
    end

    context "origin" do
      it "has a username of 'jdoe'" do
        @parsed_sdp.session_description.username.should == 'jdoe'
      end

      it "has a session_id of '2890844526'" do
        @parsed_sdp.session_description.id.should == 2890844526
      end

      it "has a session_version of '2890842807'" do
        @parsed_sdp.session_description.version.should == 2890842807
      end

      it "has a net_type of 'IN'" do
        @parsed_sdp.session_description.network_type.should == "IN"
      end

      it "has a address_type of 'IP4'" do
        @parsed_sdp.session_description.address_type.should == "IP4"
      end

      it "has a unicast_address of '10.47.16.5'" do
        @parsed_sdp.session_description.unicast_address.should == "10.47.16.5"
      end
    end

    it "has a session name of 'SDP Seminar'" do
      @parsed_sdp.session_description.name.should == "SDP Seminar"
    end

    it "has a session information of 'A Seminar on the session description protocol'" do
      @parsed_sdp.session_description.information.should == "A Seminar on the session description protocol"
    end

    it "has a URI of 'http://www.example.com/seminars/sdp.pdf'" do
      @parsed_sdp.session_description.uri.should == "http://www.example.com/seminars/sdp.pdf"
    end

    it "has an email address of 'j.doe@example.com (Jane Doe)'" do
      @parsed_sdp.session_description.email_address.should == "j.doe@example.com (Jane Doe)"
    end

    it "has a phone number of '+1 617 555-6011'" do
      @parsed_sdp.session_description.phone_number.should == "+1 617 555-6011"
    end

    context "bandwidth" do
      it "has a bandwidth type of 'CT'" do
        @parsed_sdp.session_description.bandwidth_type.should == "CT"
      end

      it "has a bandwidth of '1000'" do
        @parsed_sdp.session_description.bandwidth.should == 1000
      end
    end

    context "timing" do
      it "has a start time of '2873397496'" do
        @parsed_sdp.session_description.start_time.should == 2873397496
      end

      it "has a stop time of '2873404696'" do
        @parsed_sdp.session_description.stop_time.should == 2873404696
      end
    end

    context "repeat times" do
      it "has a repeat interval of '604800'" do
        @parsed_sdp.session_description.repeat_interval.should == 604800
      end

      it "has an active duration of '3600'" do
        @parsed_sdp.session_description.active_duration.should == 3600
      end

      it "has a offsets from start time of '0 90000'" do
        @parsed_sdp.session_description.offsets_from_start_time.should == '0 90000'
      end
    end

    context "time zones" do
      it "has a time zone adjustment of '2882844526'" do
        @parsed_sdp.session_description.time_zones[:adjustment_time].should == 2882844526
      end

      it "has a time zone offset of '-1h'" do
        @parsed_sdp.session_description.time_zones[:offset].should == '-1h'
      end
    end

    context "connection data" do
      it "has a connection network type of 'IN'" do
        @parsed_sdp.session_description.connection_network_type.should == "IN"
      end

      it "has a addrtype of :IP4" do
        @parsed_sdp.session_description.connection_address_type.should == "IP4"
      end

      it "has a connection address of '224.2.17.12/127'" do
        @parsed_sdp.session_description.connection_address.should == '224.2.17.12/127'
      end
    end

    context "session attributes" do
      it "has an attribute of type 'recvonly' with an empty value" do
        @parsed_sdp.session_description.attributes[0][:attribute].should == 'recvonly'
        @parsed_sdp.session_description.attributes[0][:value].should == nil
      end

      it "has a second attribute 'type' with value 'test'" do
        @parsed_sdp.session_description.attributes[1][:attribute].should == 'type'
        @parsed_sdp.session_description.attributes[1][:value].should == 'test'
      end
    end
  end

  describe "PROTOCOL_VERSION" do
    it "has an PROTOCOL_VERSION constant defined" do
      SDP::SessionDescription.const_defined?('PROTOCOL_VERSION').should be_true
    end

    it "is set to 0" do
      SDP::SessionDescription::PROTOCOL_VERSION.should == 0
    end
  end
end
