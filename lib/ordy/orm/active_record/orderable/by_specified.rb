module Ordy
  module Orm
    module ActiveRecord
      module Orderable
        class BySpecified
          # @param [Model::ActiveRecord_Relation] scope
          # @param [Hash] args (:table, :column)
          def self.call(scope, args)
            connection = scope.connection
            table = connection.quote_table_name(args[:table])
            column = connection.quote_column_name(args[:column])
            values = args[:values].map { |value| connection.quote(value) }

            sql = values.map { |value| "#{table}.#{column}=#{value} DESC" }.join(',')

            connection.quote(sql)
            scope.order(Arel.sql(sql))
          end
        end
      end
    end
  end
end