module Rocker
  module Instructions
    class From
      attr_reader :image_id_or_repo_tag

      def initialize(image_id_or_repo_tag)
        @image_id_or_repo_tag = image_id_or_repo_tag
      end

      def run(image)
        find_local_image_by_id || find_local_image_by_repotag || pull_image
      end

      def local_images
        Docker::Image.all
      end

      def find_local_image_by_id
        local_images.find { |image| image.id == image_id_or_repo_tag }
      end

      def find_local_image_by_repotag
        image_id_or_repo_tag << ':latest' unless image_id_or_repo_tag.include?(':')
        local_images.find { |image| image.info['RepoTags'].include?(image_id_or_repo_tag) }
      end

      def pull_image
        Docker::Image.create('fromImage' => image_id_or_repo_tag)
      end
    end
  end
end