module Ordy
  module Orm
    module ActiveRecord
      module Orderable

        def self.included(base)
          base.extend(Order::ClassMethods)
        end

        class Order
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

          def perform_ordering(scope, type, args: {})
            type.call(scope, args)
          end

          def default(name = nil, &block)
            @default = -> { order_by(name => :asc) } if name.present?
            @default ||= block if block_given?
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
            # @param [Hash] order_query
            def order_by(order_query = nil)
              return default_order if order_query.blank?

              specs = order_query.symbolize_keys.each_with_object([]) do |(orderable, direction), result|
                result << { orderable: orderable, direction: direction }
              end

              return default_order if specs.blank?

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
              # binding.pry
              orderable[:orderable].call(default_scope, orderable[:args])
            end

            def default_order
              default_scope.instance_exec(&@_orderables.default)
            end

            private

            def default_scope
              current_scope || where(nil)
            end
          end
        end
      end
    end
  end
end