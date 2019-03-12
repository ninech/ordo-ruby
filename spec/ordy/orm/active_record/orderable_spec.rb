require 'spec_helper'
require './spec/support/orm/active_record/active_record_test_db'

describe Ordy::Orm::ActiveRecord::Orderable do

  describe '#order_by' do

    context 'columns' do
      let(:base_query) { User }
      let(:order) { base_query.order_by(order_by) }
      let(:result) { order.pluck(:name) }

      context 'order by name: :asc' do
        let(:order_by) { { name: :asc } }
        specify { expect(result).to eq(%w(axample demo example)) }
      end

      context 'order by name-asc' do
        let(:order_by) { 'name-asc' }
        specify { expect(result).to eq(%w(axample demo example)) }
      end

      context 'order by name: :desc' do
        let(:order_by) { { name: :desc } }
        specify { expect(result).to eq(%w(example demo axample)) }
      end

      context 'order by name-desc' do
        let(:order_by) { 'name-desc' }
        specify { expect(result).to eq(%w(example demo axample)) }
      end

      context 'base query immutability' do
        it 'should not change base query' do
          query = base_query.where(name: 'example')
          query.order_by(name: :desc).pluck(:name)
          expect(query.to_sql).to eq('SELECT "users".* FROM "users" WHERE "users"."name" = \'example\'')
        end
      end
    end

    context 'associations' do
      let(:base_query) { User }
      let(:order) { base_query.order_by(order_by) }
      let(:result) { order.pluck(:id) }

      context 'order by name: :asc' do
        let(:order_by) { { comments: :asc } }
        specify { expect(result).to eq([3, 2, 1]) }
      end

      context 'order by name-asc' do
        let(:order_by) { 'comments-asc' }
        specify { expect(result).to eq([3, 2, 1]) }
      end

      context 'order by name: :desc' do
        let(:order_by) { { comments: :desc } }
        specify { expect(result).to eq([1, 2, 3]) }
      end

      context 'order by name-desc' do
        let(:order_by) { 'comments-desc' }
        specify { expect(result).to eq([1, 2, 3]) }
      end

      context 'base query immutability' do
        it 'should not change base query' do
          query = base_query.where(name: 'example')
          query.order_by(comments: :desc).pluck(:id)
          expect(query.to_sql).to eq('SELECT "users".* FROM "users" WHERE "users"."name" = \'example\'')
        end
      end
    end

    context 'query' do
      let(:base_query) { User }
      let(:order) { base_query.order_by(order_by) }
      let(:result) { order.pluck(:email) }

      context 'order by name: :asc' do
        let(:order_by) { { custom_query: :asc } }
        specify { expect(result).to eq(%w(example@example.com custom_example@example.com)) }
      end

      context 'order by name-asc' do
        let(:order_by) { 'custom_query-asc' }
        specify { expect(result).to eq(%w(example@example.com custom_example@example.com)) }
      end

      context 'order by name: :desc' do
        let(:order_by) { { custom_query: :desc } }
        specify { expect(result).to eq(%w(custom_example@example.com example@example.com)) }
      end

      context 'order by name-desc' do
        let(:order_by) { 'custom_query-desc' }
        specify { expect(result).to eq(%w(custom_example@example.com example@example.com)) }
      end

      context 'base query immutability' do
        it 'should not change base query' do
          query = base_query.where(name: 'example')
          query.order_by('custom_query-desc').pluck(:email)
          expect(query.to_sql).to eq('SELECT "users".* FROM "users" WHERE "users"."name" = \'example\'')
        end
      end
    end

    context 'default ordering' do
      let(:spacing) { ENV['BUNDLE_GEMFILE'].include?('gemfiles/rails_4.gemfile') ? '  ' : ' ' }

      context 'default proc' do
        let(:query) { User.where(name: 'example') }

        it 'should return asc ordering for nil' do
          expect(query.order_by(nil).to_sql).to eq('SELECT "users".* FROM "users" WHERE "users"."name" = \'example\'' + spacing + 'ORDER BY "users"."state"=\'active\' DESC,"users"."state"=\'pending\' DESC, users.name asc')
        end

        it 'should not mutate base query' do
          expect(query.to_sql).to eq('SELECT "users".* FROM "users" WHERE "users"."name" = \'example\'')
        end
      end

      context 'default field direction' do
        let(:query) { User.where(name: 'example') }

        it 'should return asc ordering for :field' do
          expect(query.order_by(:name).to_sql).to eq('SELECT "users".* FROM "users" WHERE "users"."name" = \'example\'' + spacing + 'ORDER BY users.name asc')
        end

        it 'should not mutate base query' do
          expect(query.to_sql).to eq('SELECT "users".* FROM "users" WHERE "users"."name" = \'example\'')
        end
      end

      context 'default ordering' do
        let(:base_query_sql) { 'SELECT "comments".* FROM "comments" WHERE "comments"."user_id" = 1' }
        let(:query) { Comment.where(user_id: 1) }

        it 'should return asc ordering for \'\'' do
          expect(query.order_by('').to_sql).to eq(base_query_sql)
        end

        it 'should not mutate base query' do
          expect(query.to_sql).to eq(base_query_sql)
        end
      end
    end
  end
end