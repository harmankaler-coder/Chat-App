from queue import Queue
import socket
import threading
import time
from typing import Dict, Optional


HOST = "127.0.0.1"
PORT = 4443


class Connection:
    def __init__(self):
        self.server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.server_socket.bind((HOST, PORT))
        self.server_socket.listen(1)

        self.conn, self.addr = self.server_socket.accept()

        threading.Thread(target=self._recv, daemon=True).start()

        self.recv_queue = Queue()
        self.queries: Dict[int, Optional[bytes]] = {}
        self._query_id = 0

    def _recv(self):
        while True:
            try:
                time.sleep(0.01)
                msg_size = self.conn.recv(4)
                msg_size = int.from_bytes(msg_size, "big")
                msg = self.conn.recv(msg_size)
                print(b"RECV: " + msg)

                if msg[:3] == b"ANS" and msg[3:7] in self.queries:
                    self.queries[msg[3:7]] = msg
                    continue

                self.recv_queue.put(msg)
            except ConnectionResetError:
                break

    def handle_recv(self, msg: bytes):
        pass

    def send(self, msg: bytes):
        try:
            print(b"SEND: " + msg)
            msg = self.handle_send()
            msg_size = len(msg)
            self.conn.sendall(msg_size.to_bytes(4, "big"))
            self.conn.sendall(msg)
        except ConnectionResetError:
            pass

    def query(self, msg: bytes, timeout: float = 1.0) -> Optional[bytes]:
        id = self._query_id
        self._query_id += 1

        self.send(b"QRY" + id.to_bytes(4, "big") + msg)
        while self.queries[id] is None and time.time() < timeout:
            time.sleep(0.01)
        return self.queries[id]
