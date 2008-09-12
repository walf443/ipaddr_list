require File.join(File.dirname(__FILE__), 'spec_helper')
require 'ipaddr_list'

describe IPAddrList do
  before do
    @ipaddr_list = %w( 192.168.0.1 127.0.0.1 )
  end

  it 'should include? in :BinarySearch' do
    ipaddr_list = IPAddrList.new(@ipaddr_list, :BinarySearch)
    ipaddr_list.should include('127.0.0.1')
  end

  it 'should not include? in :BinarySearch' do
    ipaddr_list = IPAddrList.new(@ipaddr_list, :BinarySearch)
    ipaddr_list.should_not include('192.168.1.1')
  end

  it 'should include? in :LinearSearch' do
    ipaddr_list = IPAddrList.new(@ipaddr_list, :LinearSearch)
    ipaddr_list.should include('127.0.0.1')
  end

  it 'should include? in :LinearSearch' do
    ipaddr_list = IPAddrList.new(@ipaddr_list, :LinearSearch)
    ipaddr_list.should_not include('192.168.1.1')
  end
end
