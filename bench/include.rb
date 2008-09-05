require 'benchmark'

$LOAD_PATH.unshift( File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib')) )
require 'ipaddr_list'

def do_benchmark ipaddr_list
  10000.times do
    ipaddr_list.include?("192.168.200.1")
  end
end

def setup algorithm
  ipaddr_list = IPAddrList.new([], algorithm
  )

  %w(
    192.168.1.1/24
    192.168.2.2/24
    192.168.3.3/24
    192.168.4.4/24
    192.168.5.5/24
    192.168.6.6/24
    192.168.7.7/24
    192.168.8.8/24
    192.168.9.9/24
    192.168.10.10/24
    192.168.11.1/24
    192.168.12.2/24
    192.168.13.3/24
    192.168.14.4/24
    192.168.15.5/24
    192.168.16.6/24
    192.168.17.7/24
    192.168.18.8/24
    192.168.19.9/24
    192.168.20.10/24
    192.168.21.1/24
    192.168.22.2/24
    192.168.23.3/24
    192.168.24.4/24
    192.168.25.5/24
    192.168.26.6/24
    192.168.27.7/24
    192.168.28.8/24
    192.168.29.9/24
    192.168.30.10/24
    192.168.31.1/24
    192.168.32.2/24
    192.168.33.3/24
    192.168.34.4/24
    192.168.35.5/24
    192.168.36.6/24
    192.168.37.7/24
    192.168.38.8/24
    192.168.39.9/24
    192.168.40.10/24
    192.168.41.1/24
    192.168.42.2/24
    192.168.43.3/24
    192.168.44.4/24
    192.168.45.5/24
    192.168.46.6/24
    192.168.47.7/24
    192.168.48.8/24
    192.168.49.9/24
    192.168.50.10/24
  ).each do |ip|
    ipaddr_list.add ip
  end

  ipaddr_list
end

ipaddr_list_of = {}
ipaddr_list_of[:linear] = setup :LinearSearch
ipaddr_list_of[:binary] = setup :BinarySearch

Benchmark.bm do |x|
  x.report 'LinearSearch' do
    do_benchmark(ipaddr_list_of[:linear])
  end

  x.report 'BinarySearch' do
    do_benchmark(ipaddr_list_of[:binary])
  end
end

# result on my environment( MacBook1.1 Intel Core Duo 1.83 GHz, 2GB), result is like that
# 
# user     system      total        real
# LinearSearch  4.820000   0.060000   4.880000 (  4.940001)
# BinarySearch  0.890000   0.010000   0.900000 (  0.914595)

