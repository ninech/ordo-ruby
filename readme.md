[![Build Status](https://travis-ci.org/ninech/ordy.svg)](https://travis-ci.org/ninech/ordy)

## Usage

#### Ordering

__Model usage__

```rb
class User < ApplicationRecord
  include Ordy::Orm::ActiveRecord::Orderable
  
  has_many :comments

  orderable_by do
    # order by field
    columns :name, :email
    
    # order by relations field
    associations comments: :scripts
    
    # sort by specified order
    specified(state: %w(new, pending, active, removed))
    
    # custom query
    query :custom_query do |scope, args|
      scope.where(name: 'example').order(email: args[:direction])
    end
  end
end
```

__Code usage__

```rb
# order by columns
User.order_by(name: :asc)
# or
User.order_by('name-asc')

# order by multiple columns
User.order_by(name: :asc, email: :desc) 
# or
User.order_by(name: :asc).order_by(email: :desc)

# order by association column
User.order_by(comments: :asc)

# order by specified column values
User.order_by_specified(:state)

# order by custom query
User.order_by(custom_query: :asc)

# default ordering
User.order_by('') 
# or
User.order_by(nil)

# ordering by more than one criteria
User.order_by(email: :asc, state: :desc)
```

#### View helper

__Helper inclusion__

```rb
# users_helper.rb 

include Ordy::Helpers::ActionView::OrderableLinkHelper
```

__Html usage__

```html
# index.html

<%= order_link('link_title', 'ordering_filed') %>
```

__Controller usage__

```rb
class UsersController
    def index
        if params[:order_by].present? && params[:direction].present?
          @users = User.order_by(params[:order_by] => params[:direction])
        else
          @users = User.all
        end
    end
end
```

## Run development environment

```bash
# position in gem dir
cd ordy

# build app
docker-compose build app

# run app and attach with bash 
docker-compose run app /bin/bash
```

## Test

```bash
# install dependencies
bundle exec appraisal install

# run tests for rails 4 env 
bundle exec appraisal rails-4 rspec

# run tests for rails 5 env
bundle exec appraisal rails-5 rspec
```