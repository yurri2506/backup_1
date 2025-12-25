================================================================================
V. THỰC NGHIỆM - PHIÊN BẢN ĐÚNG VỚI DỮ LIỆU THỰC TẾ
================================================================================

\section{Thực nghiệm}

\subsection{Thiết lập môi trường thực nghiệm}

Để đánh giá hiệu năng của các phương pháp đề xuất trong AggLayer, chúng tôi
thiết lập môi trường thực nghiệm với ba ngữ cảnh khác nhau:

\textbf{Ngữ cảnh 1: Chỉ LMTR (V4 Architecture)}
\begin{itemize}
    \item \textbf{Hệ thống:} AggLayer với chỉ LMTR4 (không có SABV)
    \item \textbf{Workflow:} Blocks → LMTR4 Rebalancing → SP1 Proving (3 bước)
    \item \textbf{Cấu hình SP1:} (4, 8) cho N ≤ 200, (3, 6) cho N > 200
    \item \textbf{Validator nodes:} 3
    \item \textbf{Mục đích:} Đánh giá tác động của LMTR4 riêng lẻ
\end{itemize}

\textbf{Ngữ cảnh 2: SABV+LMTR - Lớp Tiền Xử Lý (V5 Architecture)}
\begin{itemize}
    \item \textbf{Hệ thống:} AggLayer với SABV5 + LMTR4 (đầy đủ lớp tiền xử lý)
    \item \textbf{Workflow:} Blocks → SABV5 → LMTR4 Rebalancing → SP1 Proving (4 bước)
    \item \textbf{Cấu hình SP1:} (1, 1) cho tất cả N
    \item \textbf{RAYON\_NUM\_THREADS:} 8 (baseline, optimal) hoặc 16
    \item \textbf{Validator nodes:} 5
    \item \textbf{Mục đích:} Đánh giá hiệu quả của pipeline tích hợp SABV+LMTR
\end{itemize}

\textbf{Ngữ cảnh 3: AggSandbox (Multi-L2)}
\begin{itemize}
    \item \textbf{Hệ thống:} AggSandbox với multi-L2 mode (L1 + L2-1 + L2-2)
    \item \textbf{Tích hợp:} SABV/LMTR với môi trường test đầy đủ
    \item \textbf{Mục đích:} Đánh giá trong môi trường thực tế với nhiều chuỗi
    \item \textbf{Lưu ý:} Cần bổ sung dữ liệu chi tiết từ experiments
\end{itemize}

\textbf{Phần cứng:}
\begin{itemize}
    \item \textbf{Bộ xử lý:} Multi-core (12+ cores, hỗ trợ tối đa 16 threads)
    \item \textbf{RAM:} 32 GB
    \item \textbf{Hệ điều hành:} Linux
\end{itemize}

\textbf{Các giá trị N được test:}
\begin{itemize}
    \item V4 (LMTR Only): N = 1, 10, 20, 50, 100, 200, 500, 700
    \item V5 (SABV+LMTR): N = 1, 10, 100, 200, 500
    \item AggSandbox: N = 1, 5, 10, 20, 50 (cần bổ sung)
\end{itemize}

\textbf{Thước đo hiệu năng:}
\begin{itemize}
    \item \textbf{Latency:} Thời gian từ lúc batch được gửi đến lúc kết thúc proving hoặc early exit
    \item \textbf{Memory Usage:} Maximum RAM (GB) sử dụng trong quá trình proving
    \item \textbf{CPU Utilization:} Tỷ lệ sử dụng CPU (\%) - chỉ thị hiệu quả đa nhân
    \item \textbf{Early Exit:} Phát hiện fraud ở giai đoạn SABV5, tránh lãng phí proving
\end{itemize}

\subsection{Phân tích kết quả}

\subsubsection{Kết quả Ngữ Cảnh 1: Chỉ LMTR (V4)}

Bảng \ref{tab:v4_results} trình bày kết quả thực nghiệm cho ngữ cảnh chỉ LMTR (V4):

\begin{table}[h]
\centering
\caption{Kết quả thực nghiệm - Chỉ LMTR (V4 Architecture)}
\label{tab:v4_results}
\begin{tabular}{c|c|c|c|c}
\hline
$N$ & Elapsed Time (h) & Max RAM (GB) & CPU (\%) & SP1 Config \\
\hline
1 & 0.39 (23:39) & 15.23 & 839 & (4, 8) \\
10 & 0.65 (38:48) & 16.94 & 901 & (4, 8) \\
20 & 0.92 (55:13) & 19.78 & 979 & (4, 8) \\
50 & 1.61 (1:36:29) & 20.37 & 1064 & (4, 8) \\
100 & 2.69 (2:41:40) & 20.22 & 1128 & (4, 8) \\
200 & 6.79 (6:47:44) & 21.33 & 1215 & (4, 8) \\
500 & 16.29 (16:17:16) & 22.39 & 1254 & (3, 6) \\
700 & 22.20 (22:12:03) & 22.41 & 1258 & (3, 6) \\
\hline
\end{tabular}
\end{table}

\textbf{Phân tích:}
\begin{itemize}
    \item Memory usage ổn định: 15-22 GB, không phụ thuộc nhiều vào N
    \item CPU utilization tăng dần với N, đạt peak ~1258\% (12.6 cores)
    \item Thời gian tăng không tuyến tính, từ 0.39h (N=1) đến 22.20h (N=700)
    \item SP1 config (3, 6) cho N > 200 giúp giảm memory pressure
\end{itemize}

\subsubsection{Kết quả Ngữ Cảnh 2: SABV+LMTR (V5)}

Bảng \ref{tab:v5_results} trình bày kết quả thực nghiệm cho ngữ cảnh SABV+LMTR (V5):

\begin{table}[h]
\centering
\caption{Kết quả thực nghiệm - SABV+LMTR (V5 Architecture)}
\label{tab:v5_results}
\begin{tabular}{c|c|c|c|c|c}
\hline
$N$ & Elapsed Time (h) & Max RAM (GB) & CPU (\%) & SP1 Config & RAYON \\
\hline
1 & 0.79 (47:34) & 17.12 & 895 & (1, 1) & 16 \\
10 & 1.03 (1:02:01) & 23.95 & 1012 & (1, 1) & 16 \\
100 & 3.67 (3:40:01)* & 20.40 & 1193 & (1, 1) & 8* \\
200 & 6.60 (6:37-6:40)* & 21.34 & 1230 & (1, 1) & 8* \\
500 & 15.80 (15:48:09) & 22.47 & 1265 & (1, 1) & 16 \\
\hline
\end{tabular}
\caption*{*Baseline optimal với RAYON\_NUM\_THREADS=8}
\end{table}

\textbf{Phân tích:}
\begin{itemize}
    \item Memory usage: 17-24 GB (cao hơn V4 do có SABV layer)
    \item CPU utilization: 895-1265\% (8.9-12.7 cores)
    \item RAYON\_NUM\_THREADS=8 (baseline) nhanh hơn 16 threads ~2-3\% do giảm contention
    \item SP1 config (1, 1) đảm bảo memory ổn định cho tất cả N
    \item Early exit: Fraud detection ở SABV5 level, tránh lãng phí ~15.8h proving cho N=500
\end{itemize}

\subsubsection{So sánh V5 vs V4}

Bảng \ref{tab:comparison} so sánh hiệu năng giữa V5 (SABV+LMTR) và V4 (LMTR Only):

\begin{table}[h]
\centering
\caption{So sánh hiệu năng V5 vs V4}
\label{tab:comparison}
\begin{tabular}{c|c|c|c}
\hline
$N$ & V4 (h) & V5 (h) & So sánh \\
\hline
1 & 0.39 & 0.79 & V4 nhanh hơn ~103\% (V5 có overhead SABV) \\
10 & 0.65 & 1.03 & V4 nhanh hơn ~58\% \\
100 & 2.69 & 3.67 & V4 nhanh hơn ~36\% \\
200 & 6.79 & 6.60* & V5 nhanh hơn ~2-3\%* \\
500 & 16.29 & 15.80 & V5 nhanh hơn ~3.0\% \\
\hline
\end{tabular}
\caption*{*Baseline optimal với RAYON\_NUM\_THREADS=8}
\end{table}

\textbf{Phân tích so sánh:}
\begin{itemize}
    \item \textbf{V5 CHẬM HƠN V4 cho N nhỏ (N ≤ 100):} Overhead của SABV5 layer
      không được bù đắp bởi lợi ích cấu hình SP1 tối ưu cho N nhỏ
    \item \textbf{V5 NHANH HƠN V4 cho N lớn (N ≥ 200):} Cấu hình SP1 tối ưu
      (1, 1) với RAYON\_NUM\_THREADS=8 bù đắp overhead SABV, đạt performance tốt hơn
    \item \textbf{Trade-off:} Bảo mật (SABV) vs Performance (N nhỏ)
    \item \textbf{Early Fraud Detection:} V5 phát hiện fraud ở giai đoạn SABV5,
      tránh lãng phí tài nguyên proving (có thể mất hàng giờ với N lớn)
\end{itemize}

\subsubsection{Kết quả Ngữ Cảnh 3: AggSandbox (Multi-L2)}

\textbf{Lưu ý:} Cần bổ sung dữ liệu chi tiết từ experiments AggSandbox với multi-L2 mode.

\textbf{Thiết lập:}
\begin{itemize}
    \item Hệ thống AggSandbox với multi-L2 mode (L1 + L2-1 + L2-2)
    \item Tích hợp SABV/LMTR với môi trường test đầy đủ
    \item Mục đích: Đánh giá trong môi trường thực tế với nhiều chuỗi
\end{itemize}

\textbf{Dự kiến:}
\begin{itemize}
    \item Baseline: N = 1, 5, 10, 20, 50 exits
    \item SABV+LMTR: N = 1, 5, 10, 20, 50 exits với 5 validators
    \item So sánh performance: 1-L2 vs Multi-L2
\end{itemize}

\subsubsection{Đánh giá chi tiết}

\textbf{Phân tích Performance theo N:}
\begin{itemize}
    \item \textbf{N ≤ 100:} V4 (LMTR Only) nhanh hơn V5 do không có overhead SABV
    \item \textbf{N ≥ 200:} V5 (SABV+LMTR) nhanh hơn V4 nhờ cấu hình SP1 tối ưu
    \item \textbf{Memory scaling:} Cả hai đều ổn định, không phụ thuộc nhiều vào N
    \item \textbf{CPU utilization:} Cả hai sử dụng hiệu quả đa nhân (8-13 cores)
\end{itemize}

\textbf{Lợi ích của Early Fraud Detection:}
\begin{itemize}
    \item V5 với SABV5 phát hiện fraud ở giai đoạn tiền xử lý (trước proving)
    \item Tránh lãng phí ~15.8 giờ proving cho N=500 nếu batch lỗi
    \item Giảm độ trễ đáng kể so với baseline phải chờ đến cuối mới phát hiện
    \item Early exit mechanism: Nếu integrity\_verified = false → dừng ngay, không prove
\end{itemize}

\textbf{Ưu điểm của LMTR:}
\begin{itemize}
    \item Cân bằng cây Merkle giúp hiệu quả proof generation nhất quán
    \item Độ phức tạp chứng minh dự đoán được qua các số lượng blocks khác nhau
    \item Memory usage ổn định, không phụ thuộc nhiều vào N
\end{itemize}

\subsubsection{Kết luận thực nghiệm}

Các kết quả thực nghiệm cho thấy:

\begin{enumerate}
    \item \textbf{LMTR cải thiện cấu trúc:} Cân bằng cây Merkle giúp hiệu quả
      proof generation nhất quán và dự đoán được
    
    \item \textbf{SABV+LMTR cải thiện bảo mật:} Phát hiện gian lận sớm ở giai
      đoạn tiền xử lý, tránh lãng phí tài nguyên proving cho batches lỗi
    
    \item \textbf{Performance tốt cho N lớn:} V5 nhanh hơn V4 ~2-3\% cho N ≥ 200
      nhờ cấu hình SP1 tối ưu, mặc dù có thêm lớp SABV
    
    \item \textbf{Trade-off bảo mật vs performance:} V5 có overhead SABV cho N nhỏ
      nhưng đảm bảo bảo mật cao và performance tốt cho N lớn
    
    \item \textbf{Cấu hình tối ưu quan trọng:} RAYON\_NUM\_THREADS=8 (baseline)
      nhanh hơn 16 threads ~2-3\% do giảm contention và overhead
\end{enumerate}

Đây là cơ sở để đề xuất áp dụng rộng rãi pipeline tích hợp trong các hệ thống
blockchain đa lớp, đặc biệt với số lượng batch lớn (N ≥ 200) và yêu cầu bảo mật cao.

