require 'thread'

# Define the number of worker threads
num_workers = 8

# Create a thread-safe Queue for jobs
job_queue = Queue.new

# Example jobs - these could be any unit of work
# For example, processing data, making HTTP requests, etc.
40.times { |i| job_queue.push(i) }

# Define a worker method that processes jobs from the queue
def process_job(job, worker_id)
  puts "Worker #{worker_id}: Processing job #{job}"
  # Simulate some work with sleep
  sleep(rand(0.1..1.0))
  puts "Worker #{worker_id}: Job #{job} completed"
end

# Create worker threads
workers = Array.new(num_workers) do |i|
  Thread.new do
    worker_id = i + 1
    # Each worker keeps processing jobs until the queue is empty
    until job_queue.empty?
      job = job_queue.pop(true) rescue nil
      process_job(job, worker_id) unless job.nil?
    end
  end
end

# Wait for all worker threads to complete
workers.each(&:join)

puts "All jobs have been processed."
