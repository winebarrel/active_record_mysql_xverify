# frozen_string_literal: true

RSpec.describe 'ActiveRecordMysqlXverify::Verifiers::AURORA_MASTER' do
  let(:conn) do
    Mysql2::Client.new(
      host: conn_spec.fetch(:host),
      username: conn_spec.fetch(:username),
      as: :array
    )
  end

  specify do
    is_active = ActiveRecordMysqlXverify::Verifiers::AURORA_MASTER.call(conn)
    expect(is_active).to be_truthy
  end
end
