module Rocker
  module Instructions
    # From instruction mimics Dockerfile's FROM
    class From
      attr_reader :id_or_repo_tag

      DEFAULT_PATH = [
        'PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
      ]

      def initialize(id_or_repo_tag)
        @id_or_repo_tag = id_or_repo_tag
      end

      def run(_)
        image = find_by_id || find_by_repotag || pull_image
        config = image.json['Config']
        config['Env'] ||= DEFAULT_PATH if config['Env'] && config['Env'].empty?
        config['Image'] = image.id

        config
      end

      def run_config(config)
        config
      end

      def local_images
        Docker::Image.all
      end

      def find_by_id
        local_images.find { |image| image.id == id_or_repo_tag }
      end

      def find_by_repotag
        id_or_repo_tag << ':latest' unless id_or_repo_tag.include?(':')
        local_images.find do |image|
          image.info['RepoTags'].include?(id_or_repo_tag)
        end
      end

      def pull_image
        Docker::Image.create('fromImage' => id_or_repo_tag) do |chunk|
          Rocker.logger.debug(" -> #{chunk}")
        end
      end
    end
  end
end

Rocker::DSL.register(:from, Rocker::Instructions::From)
