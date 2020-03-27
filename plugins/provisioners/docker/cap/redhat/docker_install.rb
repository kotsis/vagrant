module VagrantPlugins
  module DockerProvisioner
    module Cap
      module Redhat
        module DockerInstall
          def self.docker_install(machine)
            if machine.guest.capability("flavor") == :rhel_8
              machine.ui.warn("Docker is not supported on RHEL 8 machines.")
              raise DockerError, :install_failed
            end
            
            machine.communicate.tap do |comm|
              comm.sudo("yum -q -y update")
              comm.sudo("yum -q -y remove docker-io* || true")
              comm.sudo("curl -fsSL https://get.docker.com/ | sh")
            end

            case machine.guest.capability("flavor")
            when :rhel_7
              docker_enable_rhel7(machine)
            else
              docker_enable_default(machine)
            end
          end

          def self.docker_enable_rhel7(machine)
            machine.communicate.tap do |comm|
              comm.sudo("systemctl start docker.service")
              comm.sudo("systemctl enable docker.service")
            end
          end

          def self.docker_enable_default(machine)
            machine.communicate.tap do |comm|
              comm.sudo("service docker start")
              comm.sudo("chkconfig docker on")
            end
          end
        end
      end
    end
  end
end
