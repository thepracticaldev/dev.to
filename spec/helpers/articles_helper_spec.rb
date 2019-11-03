require "rails_helper"

describe ArticlesHelper do
  describe ".get_host_without_www" do
    it "drops the www off of a valid url" do
      host = helper.get_host_without_www("https://www.example.com")
      expect(host).to eq "example.com"
    end

    it "lowercases the host name in general" do
      host = helper.get_host_without_www("https://www.EXAMPLE.COM")
      expect(host).to eq "example.com"
    end

    it "titlecases the host for medium.com and drops .com" do
      host = helper.get_host_without_www("https://www.medium.com")
      expect(host).to eq "Medium"
    end

    it "can handle urls without schemes" do
      host = helper.get_host_without_www("www.example.com")
      expect(host).to eq "example.com"
    end
  end

  describe "#image_tag_or_inline_svg" do
    helper do
      def internal_navigation?
        true
      end
    end
    subject { helper.image_tag_or_inline_svg("twitter") }

    it { is_expected.to include('<img class="icon-img" alt="twitter logo" src="/assets/twitter-logo') }

    context "with a width and height" do
      subject { helper.image_tag_or_inline_svg("twitter", width: 18, height: 18) }

      it { is_expected.to include('<img class="icon-img" alt="twitter logo" width="18" height="18" src="/assets/twitter-logo') }
    end

    describe "#internal_navigation? returns false" do
      before { allow(helper).to receive(:internal_navigation?).and_return(false) }

      it { is_expected.to include('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 612 612" class="icon-img" role="img"') }
    end

    describe "with a width and height and #internal_navigation? returns false" do
      subject { helper.image_tag_or_inline_svg("twitter", width: 18, height: 18) }

      before { allow(helper).to receive(:internal_navigation?).and_return(false) }

      it { is_expected.to include('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 612 612" class="icon-img" height="18" width="18" role="img"') }
    end
  end
end
