#include <arpa/inet.h>
#include <assert.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <netinet/ip_icmp.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <chrono>
#include <poll.h>
#include <iostream>
#include <set>

const int TIME_LIMIT = 1000;

uint16_t compute_icmp_checksum(const void *buff, int length)
{
    const uint16_t* ptr = static_cast<const uint16_t*> (buff);
    uint32_t sum = 0;
    assert (length % 2 == 0);
    for (; length > 0; length -= 2)
        sum += *ptr++;
    sum = (sum >> 16U) + (sum & 0xffffU);
    return ~(sum + (sum >> 16U));
}

void print_as_bytes (unsigned char* buff, ssize_t length)
{
    for (ssize_t i = 0; i < length; i++, buff++)
        printf("%.2x ", *buff);
}

bool in_array(uint16_t* array, int length, uint16_t val){
    for(int i = 0; i < length; i++)
    {
        if(array[i] == val){
            return true;
        }
    }
    return false;
}

void rt_error(std::string error_msg){
    throw std::runtime_error(error_msg);
}

void send(uint16_t* sended_pid, uint16_t* sended_seq, uint16_t* seq, int sock_fd, struct sockaddr_in recipient, int ttl){
    for (int i = 0; i < 3; i++){

        pid_t pid = getpid();
        uint16_t check_sum;
        uint16_t header_pid = (pid + *seq) & 0xFFFF;

        struct icmp header;
        header.icmp_type = ICMP_ECHO;
        header.icmp_code = 0;
        header.icmp_cksum = 0;
        header.icmp_id = htons(header_pid);  
        header.icmp_seq = htons(*seq);   
        
        check_sum = compute_icmp_checksum((uint16_t*)&header, sizeof(header));
        header.icmp_cksum = check_sum; 

        setsockopt(sock_fd, IPPROTO_IP, IP_TTL, &ttl, sizeof(int));
        
        sendto(
            sock_fd,
            &header,
            sizeof(header),
            0,
            (struct sockaddr*)&recipient,
            sizeof(recipient)
        );
        
        sended_pid[i] = header_pid;
        sended_seq[i] = *seq;
        (*seq) += 1;        
    }
}

void print_data(int received, std::set<std::string> ip_reply, int sum_time){
    if(received == 0){
        std::cout << "*";
    }
    else {
        for (auto it = ip_reply.begin(); it != ip_reply.end(); ++it) {
            std::cout << *it << " ";

        }

        if(received == 3){
            std::cout << sum_time/3 << " ms";
        }
        else{
            std::cout << "???";   
        }
    }

    std::cout << std::endl;
}

auto get_time(){
    return std::chrono::duration_cast<std::chrono::milliseconds>(
        std::chrono::system_clock::now().time_since_epoch()
    ).count();
}

bool check_ip_format(const char* ip_str){
    // just to execute funciton, useless
    char placeholder[sizeof(struct in_addr)];

    int result = inet_pton(AF_INET, ip_str, placeholder);
    return result == 1;  
}
const char* validate_input(int argc, char *argv[]) {

    if(argc != 2){
        throw std::invalid_argument("Invalid number of arguments");
    }
    char* input = argv[1];
    
    if(!check_ip_format(input)){
        throw std::invalid_argument("Received incorrect IP address");
    }
    
    return input;
}


void receive(uint16_t sended_sum[3], uint16_t sended_seq[3], int sock_fd, struct pollfd& ps, int ttl, const char* ip){
    std::cout << ttl << ": ";

    auto START_TIME = get_time();
    auto TIME = START_TIME;
    int TIME_LEFT = TIME_LIMIT;
    bool achived_destination = 0;

    int received = 0;
    std::set<std::string> ip_reply = {};
    int reply_times_sum = 0;

    while(TIME - START_TIME < TIME_LIMIT && received < 3){

        int ready = poll(&ps, 1, TIME_LEFT);

        if(ready < 0)
        {
            rt_error("poll() returned value < 0: signal problem");
        }
        else if (ready > 0 && ps.revents == POLLIN){
            int RECEIVE_TIME = get_time();
            
            while(ready > 0){
                struct sockaddr_in sender;
                socklen_t sender_len = sizeof(sender);
                uint8_t buffer[IP_MAXPACKET];

                // (struct sockaddr*)&sender - sender addres stucture
                ssize_t packet_len = recvfrom(sock_fd, buffer, IP_MAXPACKET, 0, (struct sockaddr*)&sender, &sender_len);

                if(packet_len < 0){
                    close(sock_fd);
                    rt_error("receiving data error");
                }
            
                struct ip* ip_header = (struct ip*) buffer;
                ssize_t ip_header_len = 4 * ip_header->ip_hl;

                struct icmp* icmp_header = (struct icmp*) (buffer + ip_header_len);

                uint16_t received_type = icmp_header->icmp_type;
                uint16_t received_pid;
                uint16_t received_seq;

                if (received_type == 11) { 
                    struct ip* orig_ip = (struct ip*)(buffer + ip_header_len + 8);
                    size_t orig_ip_len = 4 * orig_ip->ip_hl;
            
                    struct icmp* icmp_11 = (struct icmp*)(buffer + ip_header_len + 8 + orig_ip_len);
                    
                    received_pid = ntohs(icmp_11->icmp_hun.ih_idseq.icd_id);
                    received_seq = ntohs(icmp_11->icmp_hun.ih_idseq.icd_seq);

                }                   
                else if (received_type == 0){
                    received_pid = ntohs(icmp_header->icmp_hun.ih_idseq.icd_id);
                    received_seq = ntohs(icmp_header->icmp_hun.ih_idseq.icd_seq);
                }

                if(in_array(sended_sum, 3, received_pid) && in_array(sended_seq, 3, received_seq)){

                    received += 1;
                    reply_times_sum += RECEIVE_TIME - START_TIME;
                    char ip_str[20];
                    // bits to str converce
                    inet_ntop(AF_INET, &(sender.sin_addr), ip_str, sizeof(ip_str));    
                    ip_reply.insert(ip_str);
                    achived_destination = std::string(ip) == ip_str;

                }

                ready -= 1;
            }

        }

        TIME = get_time();
        TIME_LEFT = TIME_LIMIT - (TIME - START_TIME);
        }


    print_data(received, ip_reply, reply_times_sum);

    if(achived_destination){
        exit(0);
    }
}



int main(int argc, char *argv[])
{    
    const char* ip = validate_input(argc, argv);  
    uint16_t seq = 1;                   
    
    int sock_fd = socket(AF_INET, SOCK_RAW, IPPROTO_ICMP);
    if(sock_fd < 0){
        rt_error("socket creation failed");
    }

    struct sockaddr_in recipient;
    memset(&recipient, 0, sizeof(recipient));
    recipient.sin_family = AF_INET;
    inet_pton(AF_INET, ip, &recipient.sin_addr); 
    struct pollfd ps;
    ps.fd = sock_fd;
    ps.events = POLLIN;
    ps.revents = 0;

    for (int ttl = 1; ttl <= 30; ttl++) {
        uint16_t sended_pid[3];  
        uint16_t sended_seq[3];  
        
        send(sended_pid ,sended_seq, &seq, sock_fd, recipient, ttl);
        receive(sended_pid, sended_seq, sock_fd, ps, ttl, ip);  
    }
    
    return 0;
}
