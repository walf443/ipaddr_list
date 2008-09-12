
require 'ipaddr'

# taking method from 1.9.0 for comparing IPAddr instance.
if RUBY_VERSION < '1.9.0'
  class IPAddr
    # This code come from Ruby 1.9
    # Compares the ipaddr with another.
    def <=>(other)
      other = coerce_other(other)

      return nil if other.family != @family

      return @addr <=> other.to_i
    end
    include Comparable

    private
    
    def coerce_other(other)
      case other
      when IPAddr
        other
      when String
        self.class.new(other)
      else
        self.class.new(other, @family)
      end
    end
  end
end

#
# SYNOPSIS
#
#   require 'ipaddr_list'
#   list = IPAddrList.new(['192.168.2.3/24', '192.168.0.100/24'], :BinarySearch)
#   list.add('192.168.1.100/24')
#   list.include?('192.168.0.30') #=> true
#
#
class IPAddrList
  module Algorithm
    # base interface for algorithm module. algorithm module should include this.
    module Lint
      def after_init ip_list=[]
        raise NotImprementedError
      end

      def each &block
        raise NotImprementedError
      end
      
      include Enumerable

      def add ip
        raise NotImprementedError
      end
    end

    # slow and simple. It's for just benchmarking script.
    module LinearSearch
      include Lint

      def after_init ip_list=[]
        @ip_list = ip_list.map {|item|
          if item.kind_of? IPAddr
            item
          else
            IPAddr.new(item.to_s)
          end
        }
      end

      def add ip
        unless ip.kind_of? IPAddr
          ip = IPAddr.new(ip.to_s)
        end
        @ip_list.push ip
      end

      $LinearCount = 0
      def each &block
        @ip_list.each(&block)
      end

      def include? ip
        if ip.kind_of? IPAddr
          ipaddr = ip
        else
          ipaddr = IPAddr.new(ip)
        end
        @ip_list.any? {|item| item.include? ipaddr }
      end
    end

    # searching ipaddress with binary search.
    module BinarySearch
      include Lint

      def after_init ip_list=[]
        @ip_list = ip_list.map {|item|
          if item.kind_of? IPAddr
            item
          else
            IPAddr.new(item.to_s)
          end
        }.sort
      end

      def add ip
        unless ip.kind_of? IPAddr
          ip = IPAddr.new(ip.to_s)
        end
        @ip_list.push(ip)
        @ip_list = @ip_list.sort
      end

      def each &block
        @ip_list.each(&block)
        self
      end

      def include? ip
        binary_search ip do |ipaddr, range|
          range.any? {|idx| @ip_list[idx].include? ipaddr }
        end
      end

      # binary search
      # SEE ALSO: http://dsas.blog.klab.org/archives/51293334.html
      def binary_search ip, &block
        ipaddr = IPAddr.new(ip)
        min_idx = 0
        max_idx = @ip_list.size - 1
        if @ip_list[max_idx] > ipaddr
          min_idx = max_idx
        elsif @ip_list[min_idx] < ipaddr
          max_idx = min_idx
        else
          span = max_idx - min_idx
          while ( ( span ) > 7 ) do
            middle_idx = span / 2 + min_idx
            middle_ip = @ip_list[ middle_idx ]
            if ipaddr >= middle_ip
              min_idx = middle_idx
            else
              max_idx = middle_idx
            end

            span = max_idx - min_idx
          end
        end

        block.call(ipaddr, min_idx..max_idx)
      end
    end
  end

  def initialize ip_list, algorithm=IPAddrList::Algorithm::BinarySearch
    unless algorithm.kind_of? Module
      algorithm = IPAddrList::Algorithm.const_get(algorithm.to_s)
    end
    self.extend(algorithm)
    @algorithm = algorithm
    after_init ip_list
  end
end

if $0 == __FILE__
  ip_list = IPAddrList.new(['192.168.2.3/24', '192.168.0.100/24'], :BinarySearch)
  ip_list.add('192.168.1.10/24')
  p ip_list.include?('192.168.1.1')
  p ip_list.include?('192.168.0.100')
end
