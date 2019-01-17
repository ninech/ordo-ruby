require 'spec_helper'
require './spec/support/orm/active_record/active_record_test_db'

describe Ordy::Orm::ActiveRecord::Orderable do
  describe '#order_by' do
    context 'columns' do
      it 'should order name asc' do
        expect(User.order_by(name: :asc).pluck(:name)).to eq(%w(axample demo example))
        expect(User.order_by('name-asc').pluck(:name)).to eq(%w(axample demo example))
      end

      it 'should order name desc' do
        expect(User.order_by(name: :desc).pluck(:name)).to eq(%w(example demo axample))
        expect(User.order_by('name-desc').pluck(:name)).to eq(%w(example demo axample))
      end

      it 'should not change base query' do
        query = User.where(name: 'example')
        query.order_by(name: :desc).pluck(:name)
        expect(query.to_sql).to eq('SELECT "users".* FROM "users" WHERE "users"."name" = \'example\'')
      end
    end

    context 'associations' do
      it 'should order by comment content asc' do
        expect(User.order_by(comments: :asc).pluck(:id)).to eq([3, 2, 1])
      end

      it 'should order by comment content desc' do
        expect(User.order_by(comments: :desc).pluck(:id)).to eq([1, 2, 3])
      end

      it 'should not change base query' do
        query = User.where(name: 'example')
        query.order_by(comments: :desc).pluck(:id)
        expect(query.to_sql).to eq('SELECT "users".* FROM "users" WHERE "users"."name" = \'example\'')
      end
    end

    context 'query' do
      it 'should order by comment content asc' do
        expect(User.order_by(custom_query: :asc).pluck(:email)).to eq(%w(example@example.com custom_example@example.com))
        expect(User.order_by('custom_query-asc').pluck(:email)).to eq(%w(example@example.com custom_example@example.com))
      end

      it 'should order by comment content desc' do
        expect(User.order_by(custom_query: :desc).pluck(:email)).to eq(%w(custom_example@example.com example@example.com))
        expect(User.order_by('custom_query-desc').pluck(:email)).to eq(%w(custom_example@example.com example@example.com))
      end

      it 'should not change base query' do
        query = User.where(name: 'example')
        query.order_by('custom_query-desc').pluck(:email)
        expect(query.to_sql).to eq('SELECT "users".* FROM "users" WHERE "users"."name" = \'example\'')
      end
    end

    context 'default ordering' do
      let(:spacing) { ENV['BUNDLE_GEMFILE'].include?('gemfiles/rails_4.gemfile') ? '  ' : ' ' }
      let(:base_query_sql) { 'SELECT "users".* FROM "users" WHERE "users"."name" = \'example\'' }

      context 'default proc' do
        let(:result) { 'SELECT "users".* FROM "users" WHERE "users"."name" = \'example\''+spacing+'ORDER BY "users"."state"=\'active\' DESC,"users"."state"=\'pending\' DESC, users.name asc' }

        specify do
          query = User.where(name: 'example')
          expect(query.order_by(nil).to_sql).to eq(result)
          expect(query.to_sql).to eq(base_query_sql)
        end
      end

      context 'default field direction' do
        let(:result) { 'SELECT "users".* FROM "users" WHERE "users"."name" = \'example\'' + spacing + 'ORDER BY users.name asc' }

        specify do
          query = User.where(name: 'example')
          expect(query.order_by(:name).to_sql).to eq(result)
          expect(query.to_sql).to eq(base_query_sql)
        end
      end

      context 'default ordering' do
        let(:base_query_sql) { 'SELECT "comments".* FROM "comments" WHERE "comments"."user_id" = 1' }

        specify do
          query = Comment.where(user_id: 1)
          expect(query.order_by('').to_sql).to eq(base_query_sql)
          expect(query.to_sql).to eq(base_query_sql)
        end
      end
    end
  end
end