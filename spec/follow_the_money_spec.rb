require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module GovKit::FollowTheMoney
  describe GovKit::FollowTheMoney do

    before(:all) do
      unless FakeWeb.allow_net_connect?
        base_uri = GovKit::FollowTheMoneyResource.base_uri.gsub(/\./, '\.')

        urls = [
          ['/base_level\.industries\.list\.php\?.*page=0',                          'business-page0.response'],
          ['/base_level\.industries\.list\.php\?.*page=1',                          'business-page1.response'],
          ['/candidates\.contributions\.php\?imsp_candidate_id=111933',             'contribution.response'],
          ['/candidates\.contributions\.php\?imsp_candidate_id=0',                  'unauthorized.response'],
        ]

        urls.each do |u|
          FakeWeb.register_uri(:get, %r|#{base_uri}#{u[0]}|, :response => File.join(FIXTURES_DIR, 'follow_the_money', u[1]))
        end
      end
    end

    it "should have the base uri set properly" do
      [Business, Contribution].each do |klass|
        klass.base_uri.should == "http://api.followthemoney.org"
      end
    end

    it "should raise NotAuthorized if the api key is not valid" do
      api_key = GovKit.configuration.ftm_apikey

      GovKit.configuration.ftm_apikey = nil

      lambda do 
        @contribution = Contribution.find(0)
      end.should raise_error(GovKit::NotAuthorized)

      @contribution.should be_nil

      GovKit.configuration.ftm_apikey = api_key
    end

    describe Business do
      it "should get a list of industries" do
        @businesses = Business.list
        @businesses.should be_an_instance_of(Array)
        @businesses.each do |b|
          b.should be_an_instance_of(Business)
        end
      end
    end

    describe Contribution do
      it "should get a list of campaign contributions for a given person" do
        pending 'This API call is restricted'
        @contributions = Contribution.find(111933)
        @contributions.should be_an_instance_of(Array)
        @contributions.each do |c|
          c.should be_an_instance_of(Contribution)
        end
      end
    end

  end
end
