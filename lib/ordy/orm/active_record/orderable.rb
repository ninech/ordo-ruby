module Ordy
  module Orm
    module ActiveRecord
      module Orderable

        def self.included(base)
          base.extend(Order::ClassMethods)
        end

        class Order
          DELIMITER = '-'.freeze
          include Enumerable

          attr_reader :model, :default

          # @param [ActiveRecord::Model] model
          def initialize(model)
            @model = model
            @orderables = {}
          end

          def each(&block)
            @orderables.each(&block)
          end

          def [](key)
            @orderables.fetch(key)
          end

          # columns :name, :email
          #
          # @param [Array][Symbol] column_names
          def columns(*column_names)
            column_names.each do |column|
              @orderables[column] = { args: { table: model.table_name, column: column },
                                      orderable: Orderable::ByColumn }
            end
          end

          # associations comment: :scripts
          #
          # @param [Array][Hash] associations
          def associations(associations)
            associations.each do |assoc, opts|
              column, association = if opts.is_a?(Hash)
                                      [opts.fetch(:column), opts.fetch(:as, assoc)]
                                    else
                                      [opts, assoc]
                                    end
              table_name = model.reflections.symbolize_keys.fetch(assoc).class_name.constantize.table_name

              @orderables[association] = { args: { association: association,
                                                   table: table_name,
                                                   column: column },
                                           orderable: Orderable::ByAssociation }
            end
          end

          # specified(state: %w(new pending_migration migrating failed))
          #
          # @param [Array][Hash] args
          def specified(args)
            args.each do |column, values|
              specified_column = "specified_#{column}".to_sym

              @orderables[specified_column] = { args: { table: model.table_name,
                                                        column: column,
                                                        values: values },
                                                orderable: Orderable::BySpecified }
            end
          end

          # query :users do |scope, args|
          #   scope.where(...).order(field: args[:direction])
          # end
          #
          # @param [Symbol] query
          # @param [Proc] block
          def query(query, &block)
            @orderables[query] = { args: {}, orderable: block }
          end

          # default do
          #   order_by_specified(:state).order_by(started: :desc, created_at: :desc)
          # end
          #
          # @param [Symbol] name
          # @param [Proc] block
          def default(name = nil, &block)
            return -> { order_by(name => :asc) } if name.present?
            @default = block if block_given?
            @default ||= -> { order(nil) }
          end

          module ClassMethods

            # orderable_by do
            #   column :name
            #   association :comments
            #   specified(state: %w(new pending_migration migrating failed))
            #
            #   query(:topics) do |scope, args|
            #     ...
            #   end
            # end
            #
            # @param [Proc] block
            def orderable_by(&block)
              @_orderables ||= Order.new(self)
              @_orderables.instance_eval(&block)
              @_orderables
            end

            # Model.order_by(name: :desc)
            #
            # Model.order_by('name-desc')
            #
            # Default direction :asc
            # Model.order_by(name)
            #
            # Call default do method or order(nil)
            # Model.order_by(nil)
            # Model.order_by('')
            #
            # @param [Hash] order_query
            def order_by(order_query = nil)
              if order_query.nil? || order_query.blank?
                return default_order
              elsif order_query.is_a?(Symbol)
                return default_order(order_query)
              end

              specs = if order_query.is_a?(String)
                        parse_order_query(order_query)
                      elsif order_query.is_a?(Hash)
                        order_query.symbolize_keys.map do |(orderable, direction)|
                          { orderable: orderable, direction: direction }
                        end
                      end

              return default_order(nil) if specs.blank?

              scope = default_scope

              specs.each do |spec|
                orderable = @_orderables[spec[:orderable]]
                orderable[:args][:direction] = spec[:direction]

                scope = orderable[:orderable].call(scope, orderable[:args])
              end

              scope
            end

            # Model.order_by_specified(:name)
            #
            # @param [Symbol] name
            def order_by_specified(name)
              orderable = @_orderables["specified_#{name}".to_sym]
              orderable[:orderable].call(default_scope, orderable[:args])
            end

            def default_order(name = nil)
              default_scope.instance_exec(&@_orderables.default(name))
            end

            private

            # @param [String] order_query
            def parse_order_query(order_query)
              orderable, direction = order_query.to_s.split(DELIMITER).map(&:to_s).map(&:strip)
              direction = 'asc' unless %w(desc asc).include?(direction)
              [{ orderable: orderable.to_sym, direction: direction.to_sym }]
            end

            def default_scope
              current_scope || where(nil)
            end
          end
        end
      end
    end
  end
end