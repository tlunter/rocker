module Rocker
  module Instructions
    # GitArchive instruction wraps the Add instruction
    class GitArchive < Add
      include Rocker::Util::LogHelper

      attr_reader :repo_path, :container_path, :options

      def initialize(repo_path, container_path, options: {})
        @repo_path = repo_path
        @container_path = container_path
        @options = options
      end

      def context
        return @output if @output
        @output = StringIO.new

        IO.popen("cd #{repo_path} && git archive --format=tar #{branch}") do |io|
          @output.write(io.read)
        end

        @output
      end

      def branch
        options[:branch] || "HEAD"
      end

      def hash_of_host_path
        context.rewind
        sha256 = Digest::SHA256.new
        sha256 << context.string
        sha256.hexdigest
      end
    end
  end
end

Rocker::DSL.register(:git_archive, Rocker::Instructions::GitArchive)
