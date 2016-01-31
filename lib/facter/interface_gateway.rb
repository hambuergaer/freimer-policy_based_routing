require 'facter'
Facter.value(:interfaces).split(',').each do |interface|
  if not interface =~ /^lo/
    Facter.add("gateway_#{interface}") do
      confine :kernel => :linux, :operatingsystem => %w{CentOS Fedora RedHat}
      setcode do
        %x{/usr/sbin/ip route | grep default | grep -i "#{interface}" |awk '{print $3}' | tr -d "\n"}
      end
    end
  end
end
