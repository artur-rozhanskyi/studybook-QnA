module Devise
  module Models
    module Recoverable
      module ClassMethods
        # extract data from attributes hash and pass it to the next method
        def send_reset_password_instructions(attributes = {})
          @data = attributes.delete(:data)&.to_unsafe_h
          recoverable = find_or_initialize_with_errors(reset_password_keys, attributes, :not_found)
          recoverable.send_reset_password_instructions(@data) if recoverable.persisted?
          recoverable
        end
      end

      # adjust so it accepts data parameter and sends it to next method
      def send_reset_password_instructions(data)
        token = set_reset_password_token
        send_reset_password_instructions_notification(token, data)
        token
      end

      # adjust so it accepts data parameter and sends to next method

      protected

      def send_reset_password_instructions_notification(token, data)
        send_devise_notification(:reset_password_instructions, token, data: data)
      end
    end
  end

  Mailers.class_eval do
    # extract data from options and set it as instance variable
    def reset_password_instructions(record, token, opts = {})
      @token = token
      @data = opts.delete :data
      devise_mail(record, :reset_password_instructions, opts)
    end
  end
end
