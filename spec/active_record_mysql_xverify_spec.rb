# frozen_string_literal: true

RSpec.describe ActiveRecordMysqlXverify do
  let(:called) { {} }

  let(:verify) do
    lambda do |_|
      called[:verify] = true
      false
    end
  end

  let(:handle_if) do
    lambda do |_|
      called[:handle_if] = true
      true
    end
  end

  let(:only_on_error) { false }

  before do
    ActiveRecordMysqlXverify.verify = verify
    ActiveRecordMysqlXverify.handle_if = handle_if
    ActiveRecordMysqlXverify.only_on_error = only_on_error
  end

  context 'when verification fails' do
    it 'is reconnecting' do
      expect(ActiveRecordMysqlXverify.logger).to receive(:info).with(
        /Invalid connection: host=[^,]+, database=[^,]+, username=[^,]+, thread_id=\d+/
      ).twice

      expect(Book.count).to be_zero

      thread_id_changes(Book) do
        expect(Book.count).to be_zero
      end

      expect(called[:verify]).to be_truthy
      expect(called[:handle_if]).to be_truthy
    end
  end

  context 'when verification succeeds' do
    let(:verify) do
      lambda do |_|
        called[:verify] = true
        true
      end
    end

    it 'does not reconnect' do
      expect(ActiveRecordMysqlXverify.logger).to_not receive(:info)

      expect(Book.count).to be_zero

      thread_id_does_not_change(Book) do
        expect(Book.count).to be_zero
      end

      expect(called[:verify]).to be_truthy
      expect(called[:handle_if]).to be_truthy
    end
  end

  context 'when only_on_error is true' do
    let(:only_on_error) { true }

    context 'when SQL execution is normal' do
      it 'does not reconnect' do
        expect(ActiveRecordMysqlXverify.logger).to_not receive(:info)

        expect(Book.count).to be_zero

        thread_id_does_not_change(Book) do
          expect(Book.count).to be_zero
        end

        expect(called[:verify]).to be_falsey
        expect(called[:handle_if]).to be_falsey
      end
    end

    context 'when SQL execution is abnormal' do
      context 'when verification fails' do
        it 'is reconnecting' do
          expect(ActiveRecordMysqlXverify.logger).to receive(:info).with(
            /Invalid connection: host=[^,]+, database=[^,]+, username=[^,]+, thread_id=\d+/
          )

          expect { Book.connection.execute('INVALID SQL') }.to raise_error(ActiveRecord::StatementInvalid)

          thread_id_changes(Book) do
            expect(Book.count).to be_zero
          end

          expect(called[:verify]).to be_truthy
          expect(called[:handle_if]).to be_truthy
        end
      end

      context 'when verification succeeds' do
        let(:verify) do
          lambda do |_|
            called[:verify] = true
            true
          end
        end

        it 'does not reconnect' do
          expect(ActiveRecordMysqlXverify.logger).to_not receive(:info)

          expect { Book.connection.execute('INVALID SQL') }.to raise_error(ActiveRecord::StatementInvalid)

          thread_id_does_not_change(Book) do
            expect(Book.count).to be_zero
          end

          expect(called[:verify]).to be_truthy
          expect(called[:handle_if]).to be_truthy
        end
      end
    end
  end

  context 'when not handled' do
    let(:handle_if) do
      lambda do |_|
        called[:handle_if] = true
        false
      end
    end

    it 'does not reconnect' do
      expect(ActiveRecordMysqlXverify.logger).to_not receive(:info)

      expect(Book.count).to be_zero

      thread_id_does_not_change(Book) do
        expect(Book.count).to be_zero
      end

      expect(called[:verify]).to be_falsey
      expect(called[:handle_if]).to be_truthy
    end
  end
end
