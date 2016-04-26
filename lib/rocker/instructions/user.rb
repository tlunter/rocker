module Rocker
  module Instructions
    class User < Base
      attr_reader :user

      def initialize(user)
        @user = user
      end

      def run_config(config)
        run_config = config.dup
        run_config['User'] = user
        run_config['Cmd'] = [
          '/bin/sh',
          '-c',
          "# USER #{user}"
        ]

        run_config
      end
    end
  end
end

Rocker::DSL.register(:user, Rocker::Instructions::User)
