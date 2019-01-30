RSpec.describe Todoable do
  it "has a version number" do
    expect(Todoable::VERSION).not_to be nil
  end

  # it "does something useful" do
  #   expect(false).to eq(true)
  # end

  describe ".get_lists" do
    it "has a key called lists" do
      response = JSON.parse(described_class.get_lists)

      expect(response.key?("lists")).to eq true
    end

    it "has a value that is an array" do
      response = JSON.parse(described_class.get_lists)

      expect(response["lists"].is_a? Array).to eq true
    end
  end

  describe "Todoable::ClientNew" do
    describe "#get_lists" do
      it "has a key called lists" do
        response = Todoable::ClientNew.new.get_lists

        expect(response.key?("lists")).to eq true
      end

      it "has a value that is an array" do
        response = Todoable::ClientNew.new.get_lists

        expect(response["lists"].is_a? Array).to eq true
      end
    end
  end
end
