RSpec.describe Todoable do
  it "has a version number" do
    expect(Todoable::VERSION).not_to be nil
  end

  describe "Todoable::Client" do
    context "for an authenticated client" do
      let(:username) { "vinod_lala@usa.net" }
      let(:password) { "todoable" }
      let(:client) { Todoable::Client.new(username: username,
                                          password: password)}

      describe "#get_lists" do
        it "has a key called lists" do
          response = client.get_lists

          expect(response.key?("lists")).to eq true
        end

        it "has a value that is an array" do
          response = client.get_lists

          expect(response["lists"].is_a? Array).to eq true
        end
      end

      describe "#get_list" do
        it "has a 'name' key" do
          id = "710fea1c-fb14-4bc6-92cf-476ba9652b29"

          response = client.get_list(id)

          expect(response.key?("name")).to eq true
        end

        it "has a 'name' value that is a string" do
          id = "710fea1c-fb14-4bc6-92cf-476ba9652b29"

          response = client.get_list(id)

          expect(response["name"].is_a? String).to eq true
        end

        it "has an 'items' key" do
          id = "710fea1c-fb14-4bc6-92cf-476ba9652b29"

          response = client.get_list(id)

          expect(response.key?("items")).to eq true
        end

        it "has an 'items' value that is an array" do
          id = "710fea1c-fb14-4bc6-92cf-476ba9652b29"

          response = client.get_list(id)

          expect(response["items"].is_a? Array).to eq true
        end
      end

      describe "#post_list" do
      end
    end
  end
end
