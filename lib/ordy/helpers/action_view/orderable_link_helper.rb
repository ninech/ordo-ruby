# frozen_string_literal: true

module Ordy
  module Helpers
    module ActionView
      module OrderableLinkHelper
        ORDER_ASC = 'asc'
        ORDER_DESC = 'desc'

        # order_link(Alert, :event, :asc)
        #
        # @param [String] title
        # @param [Symbol] order_by
        # @param [Symbol] direction
        def order_link(title, order_by, direction = ORDER_ASC)
          current_orderable, current_direction = request_params.values_at(:order_by, :direction)

          direction = if current_direction.present?
                        current_direction == ORDER_ASC ? ORDER_DESC : ORDER_ASC
                      else
                        direction
                      end

          icon_html = if current_orderable.present? && order_by.to_s == current_orderable
                        icon(direction)
                      else
                        icon(nil)
                      end

          title = "#{title} #{icon_html}".html_safe
          url_params = request_params.merge(order_by: "#{order_by}-#{direction}")

          link_to(title, url_params)
        end

        # NOTE: In case you don't use Awesome Font override this method
        #
        # icon('asc')
        #
        # @param [String] direction
        # @return [String]
        def icon(direction = nil)
          icon, html_class = if direction.nil?
                               [config.icon.sort, class: config.icon.inactive]
                             else
                               [direction == ORDER_DESC ? config.icon.up : config.icon.down, nil]
                             end
          icon_class = "fa-#{icon}"

          "<i class=\"fa #{icon_class} #{html_class}\"></i>"
        end

        private

        def request_params
          request.params
        end
      end
    end
  end
end