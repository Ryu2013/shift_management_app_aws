require 'rails_helper'

RSpec.describe "StaticPages", type: :request do
  describe "GET /terms" do
    it "returns http success" do
      get terms_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /privacy_policy" do
    it "returns http success" do
      get privacy_policy_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /specified_commercial_transactions" do
    it "returns http success" do
      get specified_commercial_transactions_path
      expect(response).to have_http_status(:success)
    end
  end
end
