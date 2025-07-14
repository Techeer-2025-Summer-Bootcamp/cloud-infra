
# gcp 사용
provider "google" {
    credentials = file("silken-psyche-465905-a6-a832473ac906.json")  # 서비스 계정 키 파일 경로
    project     = "silken-psyche-465905-a6"
    region      = "asia-northeast3"  # 서울 리전
    zone        = "asia-northeast3-a"  # 서울 리전 가용영역 a
}

# 인스턴스 접속에 필요한 ssh key 추가
variable "ssh_key" {
    type        = string
    description = "SSH public key"
}

# 네트워크 추가
resource "google_compute_network" "vpc_network" {
    name                    = "session-vpc-network"
    auto_create_subnetworks = false
}

# 서브넷 추가
resource "google_compute_subnetwork" "subnet" {
    name          = "session-subnet"
    ip_cidr_range = "10.0.0.0/16"
    network       = google_compute_network.vpc_network.id
    region        = "asia-northeast3"  # 서울 리전
}

# 고정 아이피 할당
resource "google_compute_address" "static_ip1" {
    name   = "session-static-ip"
    region = "asia-northeast3"  # 서울 리전
}

# 방화벽 설정
resource "google_compute_firewall" "main-ssh-icmp" {
    name    = "main-ssh-icmp"
    network = google_compute_network.vpc_network.name

    allow {
        protocol = "tcp"
        ports    = ["22", "80", "443"]  # 포트 설정
    }

    allow {
        protocol = "icmp"
    }

    source_ranges = ["0.0.0.0/0"]
    target_tags = ["main-firewall"] # 방화벽 태그 설정
}

# 이미지 데이터
data "google_compute_image" "ubuntu" {
  family  = "ubuntu-2204-lts"
  project = "ubuntu-os-cloud"
}


# 인스턴스 생성 
resource "google_compute_instance" "vm_instance1" {
    name         = "session-instance2"
    machine_type = "e2-medium"  # 2 vCPUs, 4GB memory
    zone         = "asia-northeast3-a"  # 서울 리전 가용영역 a
    allow_stopping_for_update = true

    boot_disk {
        initialize_params {
           image = data.google_compute_image.ubuntu.self_link
           size  = 30
           type  = "pd-balanced"
        }   
    }

    network_interface {
        subnetwork = google_compute_subnetwork.subnet.id
        access_config {
            nat_ip = google_compute_address.static_ip1.address
        }
    }

    tags = ["http-server", "https-server", "main-firewall"]
    
    metadata = {
        ssh-keys = "ubuntu:${var.ssh_key}"
        startup-script = file("docker.sh")
    }
}
