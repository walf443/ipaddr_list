
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
  module Algorism
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

    # searching ipaddress with binary.
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
          ip = IPAddr.new(ip)
        end
        @ip_list.push(ip)
        @ip_list = @ip_list.sort
      end

      def each &block
        @ip_list.each(&block)
        self
      end

      def include? ip
        # binary search
        # SEE ALSO: http://dsas.blog.klab.org/archives/51293334.html
        remote = IPAddr.new(ip)
        min_idx = 0
        max_idx = @ip_list.size - 1
        span = max_idx - min_idx
        while ( ( span ) > 7 ) do
          middle_idx = span / 2 + min_idx
          middle_ip = @ip_list[ middle_idx ]
          if remote >= middle_ip
            min_idx = middle_idx
          else
            max_idx = middle_idx
          end

          span = max_idx - min_idx
        end

        # linear search for checking valid ip
        ( min_idx .. max_idx ).any? {|idx| @ip_list[idx].include? remote }
      end
    end
  end

  def initialize ip_list, algorism=IPAddrList::Algorism::BinarySearch
    unless algorism.kind_of? Module
      algorism = IPAddrList::Algorism.const_get(algorism.to_s)
    end
    self.extend(algorism)
    @algorism = algorism
    after_init ip_list
  end
end

if $0 == __FILE__
  ip_list = IPAddrList.new(['192.168.2.3/24', '192.168.0.100/24'], :BinarySearch)
  ip_list.add('192.168.1.10/24')
end
