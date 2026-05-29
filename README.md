# Slaytistics Data Explorers 2026 - TNBike Analytics

Dự án xây dựng hệ thống phân tích dữ liệu cho TNBike, bao gồm pipeline xử lý đơn hàng tự động từ Email/PDF, cơ sở dữ liệu PostgreSQL/Neon, dashboard Power BI và mô hình dự báo Q2/2026.

Mục tiêu chính của dự án là biến dữ liệu đơn hàng rời rạc thành nguồn dữ liệu có thể kiểm soát, truy vết và sử dụng cho phân tích kinh doanh.

---

## 1. Tổng quan hệ thống

Pipeline tổng thể được triển khai theo luồng:

```text
Email/PDF đơn hàng tháng 3/2026
        ↓
Kaggle ETL Pipeline
Parse email/PDF → Validate → Mapping customer/product
        ↓
Neon Cloud PostgreSQL
Staging → Review Queue → Fact/Dim → Dashboard-ready View
        ↓
Power BI Dashboard
        ↓
Forecasting Model Q2/2026
```

Hệ thống không chỉ nhập dữ liệu đơn hàng, mà còn kiểm soát chất lượng dữ liệu qua các lớp mapping, validation, review queue và enrichment.

---

## 2. Cấu trúc thư mục

```text
.
├── .github/workflows/
│   └── export-neon-cloud-postgresql.yml
│
├── Dashboard/
│   └── [Slaytistics] - Dashboard Vòng 2.pbix
│
├── Forecasting Model/
│   ├── tnbike-forecast.ipynb
│   └── Outputs/
│       ├── Results/
│       └── Image Results/
│
├── Pipeline EML - PDF/
│   ├── tnbike-pipeline-eml-pdf.ipynb
│   └── Outputs/
│
├── PostgreSQL/
│   ├── Local/
│   │   ├── 01_create_tables.sql
│   │   ├── 02_import_data.sql
│   │   ├── 03_create_email_log.sql
│   │   └── 04_refresh_fact_sales.sql
│   │
│   └── Cloud PostgreSQL/
│       ├── tnbike_neon_full_dump.sql
│       ├── v_fact_sales_dashboard_march_2026.csv
│       ├── dashboard_ready_validation_result.csv
│       ├── customer_mapping_review_final.csv
│       ├── product_mapping_review_final.csv
│       ├── product_classification_kpi_full_period.csv
│       └── geo_enrichment_kpi_full_period.csv
│
├── Reports/
│   ├── BaoCao_KyThuat_TNBike_Q2_2026.pdf
│   └── PPT_VÒNG 2_FINAL_SLAYTISTICS_.pptx
│
├── .gitignore
└── README.md
```

---

## 3. Dashboard

Thư mục:

```text
Dashboard/
```

Chứa file Power BI:

```text
[Slaytistics] - Dashboard Vòng 2.pbix
```

Dashboard sử dụng dữ liệu đã được chuẩn hóa từ PostgreSQL/Neon, bao gồm dữ liệu bán hàng, vận hành pipeline, chất lượng dữ liệu, mapping/review queue và các chỉ số phân tích kinh doanh.

Nguồn dữ liệu chính cho dashboard là view:

```sql
tnbike.v_fact_sales_dashboard
```

Power BI nên sử dụng các cột final:

```text
customer_code_final
customer_name_final
province_name_final
region_final
line_name_final
group_code_final
group_name_final
product_classification_status
geo_mapping_status
customer_mapping_status
```

Không nên dùng trực tiếp các cột raw như:

```text
province_name
region
line_name
group_code
group_name
```

---

## 4. Pipeline EML - PDF

Thư mục:

```text
Pipeline EML - PDF/
```

Chứa notebook ETL:

```text
tnbike-pipeline-eml-pdf.ipynb
```

Đây là phần xử lý đơn hàng tự động cho Hạng mục A.

Pipeline thực hiện:

1. Đọc 1.132 email `.eml`.
2. Trích xuất header, body email và file PDF đính kèm.
3. Parse PDF bằng `pdfplumber`.
4. Validate số đơn, ngày đơn, dòng hàng, số lượng, đơn giá và thành tiền.
5. Mapping customer theo MST và fuzzy matching tên đại lý.
6. Mapping product theo product code, extra product code và fuzzy product name.
7. Tạo staging data, review queue và log vận hành.
8. Nạp dữ liệu vào Neon PostgreSQL.

Kết quả ETL tháng 3/2026:

| Chỉ tiêu | Kết quả |
|---|---:|
| Email/PDF xử lý | 1.132 |
| SUCCESS | 1.129 |
| NEEDS_REVIEW | 3 |
| FAILED | 0 |
| Đơn hàng | 1.132 |
| Dòng hàng | 8.723 |
| Số lượng | 25.607 xe |
| Doanh thu | 40.804.047.133 VND |

Ba đơn `NEEDS_REVIEW` không phải lỗi kỹ thuật pipeline. Đây là các đơn đã đọc được dữ liệu, nhưng customer chưa đủ độ tin cậy để tự động map vào master data.

---

## 5. PostgreSQL

Thư mục:

```text
PostgreSQL/
```

được chia thành hai phần:

```text
PostgreSQL/Local
PostgreSQL/Cloud PostgreSQL
```

### 5.1 Local PostgreSQL

Thư mục:

```text
PostgreSQL/Local/
```

Chứa các file SQL ban đầu dùng để thiết kế và thiết lập database local:

```text
01_create_tables.sql
02_import_data.sql
03_create_email_log.sql
04_refresh_fact_sales.sql
```

Phần Local chủ yếu phục vụ bước chuẩn bị schema, bảng lõi và thử nghiệm ban đầu. Phần này không phải nơi đọc trực tiếp 1.132 email `.eml`; việc đọc email/PDF được thực hiện trong notebook Kaggle ở thư mục `Pipeline EML - PDF`.

### 5.2 Cloud PostgreSQL / Neon

Thư mục:

```text
PostgreSQL/Cloud PostgreSQL/
```

Chứa dữ liệu được export tự động từ Neon Cloud PostgreSQL bằng GitHub Actions.

Các file chính:

```text
tnbike_neon_full_dump.sql
v_fact_sales_dashboard_march_2026.csv
dashboard_ready_validation_result.csv
customer_mapping_review_final.csv
product_mapping_review_final.csv
product_classification_kpi_full_period.csv
geo_enrichment_kpi_full_period.csv
```

Ý nghĩa:

| File | Mô tả |
|---|---|
| `tnbike_neon_full_dump.sql` | Dump schema/data từ Neon PostgreSQL |
| `v_fact_sales_dashboard_march_2026.csv` | Export view dashboard-ready tháng 3/2026 |
| `dashboard_ready_validation_result.csv` | Kết quả kiểm tra dữ liệu cuối |
| `customer_mapping_review_final.csv` | Danh sách customer cần review |
| `product_mapping_review_final.csv` | Danh sách product cần enrichment/review |
| `product_classification_kpi_full_period.csv` | KPI phân loại sản phẩm toàn kỳ |
| `geo_enrichment_kpi_full_period.csv` | KPI bổ sung tỉnh/vùng toàn kỳ |

---

## 6. GitHub Actions - Export Neon Cloud PostgreSQL

Workflow:

```text
.github/workflows/export-neon-cloud-postgresql.yml
```

Workflow này dùng để export dữ liệu từ Neon PostgreSQL về GitHub.

Cách hoạt động:

1. GitHub Actions đọc secret `DATABASE_URL`.
2. Kết nối tới Neon Cloud PostgreSQL.
3. Export database dump bằng `pg_dump`.
4. Export các CSV evidence từ `tnbike.v_fact_sales_dashboard` và các bảng review/enrichment.
5. Commit file export vào thư mục:

```text
PostgreSQL/Cloud PostgreSQL/
```

Connection string Neon không được hard-code trong source code. Thay vào đó, workflow dùng GitHub Secret:

```text
DATABASE_URL
```

Điều này giúp repo có thể lưu bằng chứng dữ liệu mà không lộ thông tin đăng nhập database.

---

## 7. Forecasting Model

Thư mục:

```text
Forecasting Model/
```

Chứa notebook:

```text
tnbike-forecast.ipynb
```

Notebook này thuộc Hạng mục C, dùng để dự báo Q2/2026 trong điều kiện dữ liệu lịch sử hạn chế.

Phương pháp sử dụng:

- Không dùng mô hình time-series đầy đủ như ARIMA/Prophet/ETS vì dữ liệu chỉ có Q1/2025 và Q1/2026.
- Dùng limited-data scenario forecasting.
- Tổng Q2/2026 được dự báo bằng run-rate Q1/2026.
- SKU/sản phẩm được phân bổ theo cơ cấu Q1/2026 kết hợp Q1/2025.
- Màu sắc được dự báo theo cơ cấu Q1/2026 và thay đổi tỷ trọng YoY.
- Đại lý được xếp hạng bằng RFM và purchase priority score.

Kết quả chính:

| Chỉ tiêu | Base Q2/2026 |
|---|---:|
| Doanh thu dự báo | ~81,33 tỷ VND |
| Sản lượng dự báo | 50.670 xe |

Backtest cấp nhóm sản phẩm:

| Mô hình | MAPE |
|---|---:|
| Naive baseline | 64,58% |
| Global YoY | 31,70% |

Kết quả forecast được dùng như công cụ hỗ trợ quyết định kinh doanh, không phải cam kết chính xác tuyệt đối.

---

## 8. Reports

Thư mục:

```text
Reports/
```

Chứa tài liệu nộp cuối:

```text
BaoCao_KyThuat_TNBike_Q2_2026.pdf
PPT_VÒNG 2_FINAL_SLAYTISTICS_.pptx
```

Bao gồm:

- Báo cáo kỹ thuật.
- Slide thuyết trình.
- Tổng hợp pipeline vận hành, dashboard, dữ liệu PostgreSQL/Neon và mô hình dự báo.

---

## 9. Kết quả nổi bật

### Pipeline vận hành

- Xử lý 1.132 email/PDF tháng 3/2026.
- 1.129 email xử lý tự động thành công.
- 3 email cần review do customer chưa đủ độ tin cậy để map.
- 0 email thất bại kỹ thuật.
- 8.723 dòng hàng được đưa vào fact sales.
- 40,804 tỷ VND doanh thu tháng 3/2026 được ghi nhận.

### Data quality

- Customer mapping dùng MST trước, sau đó fuzzy matching theo tên.
- Product mapping dùng product code exact, extra product code và fuzzy product name.
- Các trường hợp không đủ tin cậy được giữ trong review queue, không ép map.
- Missing geo final = 0.
- Validation cuối đạt 10/10 checks.

### Forecasting

- Q2/2026 base forecast: ~81,33 tỷ VND và 50.670 xe.
- Nhóm chủ lực: Xe phổ thông.
- Màu ưu tiên: Kem, Đen, Ghi, Hồng, Xanh.
- Dealer scoring dùng purchase priority score, không gọi là xác suất thống kê tuyệt đối.

---

## 10. Lưu ý bảo mật

Repo không nên chứa connection string Neon hoặc password database.

Không commit các dòng dạng:

```python
NEON_CONN = "postgresql://..."
DATABASE_URL = "postgresql://..."
```

Thông tin kết nối Neon được lưu bằng GitHub Secret:

```text
DATABASE_URL
```

Nếu connection string từng bị lộ trong notebook hoặc ảnh chụp, cần rotate password/secret trên Neon.

---

## 11. Kết luận

Dự án đã xây dựng được hệ thống dữ liệu tương đối đầy đủ từ pipeline xử lý đơn hàng, Cloud PostgreSQL, dashboard Power BI đến mô hình dự báo Q2/2026.

Điểm quan trọng của hệ thống là không tự động hóa mù quáng. Các trường hợp chắc chắn được tự động xử lý, còn các trường hợp không đủ độ tin cậy được đưa vào review queue để giữ tính kiểm soát, truy vết và độ tin cậy dữ liệu.
