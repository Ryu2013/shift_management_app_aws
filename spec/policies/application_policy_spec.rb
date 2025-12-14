# spec/policies/application_policy_spec.rb
require 'rails_helper'

RSpec.describe ApplicationPolicy, type: :policy do
  # テスト用のダミーデータ（DB保存不要なので new や double でOK）
  let(:user) { User.new }
  let(:record) { double('Record') }

  # ポリシーのインスタンス化
  subject { described_class.new(user, record) }

  describe "デフォルトの権限設定" do
    it "index? は false を返す" do
      expect(subject.index?).to be false
    end

    it "show? は false を返す" do
      expect(subject.show?).to be false
    end

    it "create? は false を返す" do
      expect(subject.create?).to be false
    end

    it "new? は false を返す" do
      expect(subject.new?).to be false
    end

    it "update? は false を返す" do
      expect(subject.update?).to be false
    end

    it "edit? は false を返す" do
      expect(subject.edit?).to be false
    end

    it "destroy? は false を返す" do
      expect(subject.destroy?).to be false
    end
  end
end
