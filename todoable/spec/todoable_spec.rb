RSpec.describe Todoable do
  it "has a version number" do
    expect(Todoable::VERSION).not_to be nil
  end

  describe "Todoable::Client" do
    describe "#get_lists" do
      it "has a key called lists" do
        response = Todoable::Client.new.get_lists

        expect(response.key?("lists")).to eq true
      end

      it "has a value that is an array" do
        response = Todoable::Client.new.get_lists

        expect(response["lists"].is_a? Array).to eq true
      end
    end

    describe "#get_list" do
    end

    describe "#post_list" do
    end
  end
end
