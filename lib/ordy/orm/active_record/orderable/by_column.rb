module Ordy
  module Orm
    module ActiveRecord
      module Orderable
        class ByColumn
          # @param [Model::ActiveRecord_Relation] scope
          # @param [Hash] args (:table, :column, :direction)
          def self.call(scope, args)
            table, column, direction = args.values_at(:table, :column, :direction)

            scope.order("#{table}.#{column} #{direction}")
          end
        end
      end
    end
  end
end