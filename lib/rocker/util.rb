require 'docker'

module Rocker
  # Utility module to build tars
  module Util
    # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    def create_relative_file_tar(file, output)
      if File.directory?(file)
        directory = file
      else
        directory = File.dirname(file)
        file = "#{directory}/#{file}" unless file.start_with?(directory)
      end

      Gem::Package::TarWriter.new(output) do |tar|
        Find.find(directory) do |prefixed_file_name|
          next unless prefixed_file_name.start_with?(file)
          stat = File.stat(prefixed_file_name)
          next unless stat.file?

          unprefixed_file_name = prefixed_file_name[directory.length..-1]
          Docker::Util.add_file_to_tar(
            tar, unprefixed_file_name, stat.mode, stat.size, stat.mtime
          ) do |tar_file|
            IO.copy_stream(File.open(prefixed_file_name, 'rb'), tar_file)
          end
        end
      end
    end
    # rubocop:enable Metrics/AbcSize,Metrics/MethodLength
    module_function :create_relative_file_tar
  end
end

