require 'spec_helper'
require './spec/support/orm/active_record/active_record_test_db'

describe Ordy::Orm::ActiveRecord::Orderable do
  describe '#order_by' do
    context 'columns' do
      it 'should order name asc' do
        expect(User.order_by(name: :asc).pluck(:name)).to eq(%w(axample demo example))
      end

      it 'should order name desc' do
        expect(User.order_by(name: :desc).pluck(:name)).to eq(%w(example demo axample))
      end
    end

    context 'associations' do
      it 'should order by comment content asc' do
        expect(User.order_by(comments: :asc).pluck(:id)).to eq([3,2,1])
      end

      it 'should order by comment content desc' do
        expect(User.order_by(comments: :desc).pluck(:id)).to eq([1,2,3])
      end
    end

    context 'query' do
      it 'should order by comment content asc' do
        expect(User.order_by(custom_query: :asc).pluck(:email)).to eq(%w(example@example.com custom_example@example.com))
      end

      it 'should order by comment content desc' do
        expect(User.order_by(custom_query: :desc).pluck(:email)).to eq(%w(custom_example@example.com example@example.com))
      end
    end
  end
end
