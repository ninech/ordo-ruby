require 'active_record'

RSpec.configure do |config|
  config.before(:all) do
    create_db
    migrate
    seed
  end

  config.after(:all) do
    drop_db
  end
end

def create_db
  ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
end

def migrate
  ActiveRecord::Base.connection.create_table :users do |t|
    t.text :name
    t.text :email
    t.text :state
  end

  ActiveRecord::Base.connection.create_table :comments do |t|
    t.integer :user_id
    t.text :content
  end
end

def seeds
  [
      { table: "'users'",
        fields: %w(id name email state),
        values: [
            [1, "'demo'", "'demo@demo.com'", "'active'"],
            [2, "'axample'", "'example@example.com'", "'pending'"],
            [3, "'example'", "'custom_example@example.com'", "'active'"]
        ]
      },
      { table: "'comments'",
        fields: %w(content user_id),
        values: [
            ["'example'", 1],
            ["'demo'", 2]
        ]
      }
  ]
end

def seed
  seeds.each do |model|
    model[:values].each do |args|
      ActiveRecord::Base.connection.execute("INSERT INTO #{model[:table]} (#{model[:fields].join(',')}) VALUES (#{args.join(',')})")
    end
  end
end

def drop_db
  [:users, :comments].each do |table|
    ActiveRecord::Base.connection.drop_table table
  end
end

class Comment < ActiveRecord::Base
  include Ordy::Orm::ActiveRecord::Orderable

  orderable_by do

  end

  belongs_to :user
end

class User < ActiveRecord::Base
  include Ordy::Orm::ActiveRecord::Orderable

  has_many :comments

  orderable_by do
    columns :name, :email
    associations comments: :content
    specified(state: %w(active pending))

    query :custom_query do |scope, args|
      scope.where('email LIKE \'%example%\'',).order(id: args.fetch(:direction))
    end

    default do
      order_by_specified(:state).order_by(:name)
    end
  end
end

