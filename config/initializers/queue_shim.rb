require "sidekiq"

module Rails
  def self.queue
    @queue ||= env.test? ? Array.new : Queuer.new
  end
  
  class Queuer  
    def push(data)
      options = data.is_a?(Sidekiq::Worker) ?
        data.class.get_sidekiq_options : Sidekiq::Worker::DEFAULT_OPTIONS
      Sidekiq::Client.push(options.merge(class: RailsProxyWorker, args: [Marshal.dump(data)]))
    end
    
    class RailsProxyWorker
      include Sidekiq::Worker
    
      def perform(blob)
        job = Marshal.load(blob)
        job.run
      end
    end
  end
end