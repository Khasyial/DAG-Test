Dokumentasi DAG Test

STRUKTUR DATA & ETL

ACCOUNT

Dalam struktur data file account.JSON terdapat 1 row menampilkan kolom Id, Status, ProvideName, DateTimeUTC & "Accounts". Dalam kolom "Accounts" terdapat sub row yang berisi banyak kolom lainnya. Dalam task ini diminta untuk mengambil kolom AccountID,  code, Name, bank_account_number, currency yang Diana kolom tersebut bisa diakses dalam subrow  "Accounts" tersebut maka untuk mengambilnya dibutuhkan 2x looping dan kemudian data tersebut baru bisa disimpan. Dalam code saya terjadi parsing yaitu mengubah format .JSON (berupa teks) diubah menjadi format struktur data python terjadi sebelum saya mengambil data yang sebelumnya saya jelaskan. Contoh file account.JSON tersebut dilampirkan dibawah
 

Isi dari file: account20250401.json
{
  "Id": "8c731e5e-f165-4efc-9c50-956891e3c16d",s
  "Status": "OK",
  "ProviderName": "API Explorer",
  "DateTimeUTC": "\/Date(1745993913166)\/",
  "Accounts": [
    {
      "AccountID": "562555f2-8cde-4ce9-8203-0363922537a4",
      "Code": "090",
      "Name": "Business Bank Account",
      "Status": "ACTIVE",
      "Type": "BANK",
      "TaxType": "NONE",
      "Class": "ASSET",
      "EnablePaymentsToAccount": false,
      "ShowInExpenseClaims": false,
      "BankAccountNumber": "0908007006543",
      "BankAccountType": "BANK",
      "CurrencyCode": "USD",
      "ReportingCode": "ASS",
      "ReportingCodeName": "Asset",
      "HasAttachments": false,
      "UpdatedDateUTC": "\/Date(1744171409413+0000)\/",
      "AddToWatchlist": false
    },
    { .....


BALANCE SHEET

Untuk Struktur data ada file balance_sheet.JSON Diana saya melakukan Hal yang sama untuk parsingnya tetapi untuk mengakses datanya berbeda karena isi file dari data tersebut memiliki 3 sub row dan 2 cara langkah berbeda. isi dari task tersebut diminta untuk mengambil kolom account, account_id, date_report, value.
Langkah pertama untuk mengambil data pada sub row yang bernama header, Hal tersebut dilakukan karena terdapat kolom date_report yang dibutuhkan. setelah itu langkah kedua mengambil data pada row section dimana dalam row tersebut memiliki sub row yang memiliki nama "row". dalam row section dapat ditemukan kołom account dań dałam sub rów bernama "rów" ditemukan account_id & value.  Dalam 1 file balance ini tulisan account, account_id, date_report, value tidak dinamakan dengan Nama kolom yang sama tetapi dinamakan dengan kolom "value" sehingga untuk mengakses tersebut harus mengubah kolom didalam "value" menjadi kolom account, account_id, date_report, value. Contoh untuk isi dari file balance_sheet.JSON tersebut dilampirkan di bawah



Isi mentah dari file: balance_sheet_20250401.json
{
  "Id": "41d0e313-bcf4-475e-8343-d18e19ed331b",
  "Status": "OK",
  "ProviderName": "API Explorer",
  "DateTimeUTC": "\/Date(1745994022278)\/",
  "Reports": [
    {
      "ReportID": "BalanceSheet",
      "ReportName": "Balance Sheet",
      "ReportType": "BalanceSheet",
      "ReportTitles": [
        "Balance Sheet",
        "Demo Company (Global)",
        "As at 30 April 2025"
      ],
      "ReportDate": "30 April 2025",
      "UpdatedDateUTC": "\/Date(1745994022262)\/",
      "Fields": [],
      "Rows": [
        {
          "RowType": "Header",
          "Cells": [
            {
              "Value": ""
            },
            {
              "Value": "30 Apr 2025"
            },
            {
              "Value": "31 Mar 2025"
            },
            { .....
          ]
        }
	{
          "RowType": "Section",
          "Title": "Assets",
          "Rows": []
        },
        {
          "RowType": "Section",
          "Title": "Bank",
          "Rows": [
            {
              "RowType": "Row",
              "Cells": [
                {
                  "Value": "Business Bank Account",
                  "Attributes": [
                    {
                      "Value": "562555f2-8cde-4ce9-8203-0363922537a4",
                      "Id": "account"
                    }
                  ]
                },
                {
                  "Value": "1760.54",
                  "Attributes": [
                    {
                      "Value": "562555f2-8cde-4ce9-8203-0363922537a4",
                      "Id": "account"
                    }
                  ]
                },
                {......


Hal yang dilakukan diatas merupakan bentuk salah satu cara saat mengekstrak data yaitu data file account untuk kolom (AccountID,  code. Name, bank_account_number, currency) dan file balance_sheet untuk kolom (account, account_id, date_report, value) yang dimana file tersebut diekstrak ke dalam bentuk format Tabel dengan menggunakan pandas agar memudahkan data untuk bisa dianalisis dan kemudian divisualisasikan.

Proses selanjutanya adalah melakukan staging setelah berhasil diekstrak dan disimpan ke dalam database SQLite sementara menggunakan DataFrame yang sebelemunya Sudan di parsing. Proses ini membuat 2 tabel staging yaitu stg_account dan stg_balance_sheet.

Setelah proses staging selesai, dibangun dua tabel utama dalam database, yaitu dim_account sebagai tabel dimensi dan fact_balance_sheet sebagai tabel fakta. Karena hanya terdapat satu tabel dimensi dan satu tabel fakta, maka skema data yang digunakan bersifat sederhana dan tidak membentuk struktur kompleks seperti star schema.

Untuk mencatat riwayat perubahan akun, diterapkan metode SCD (Slowly Changing Dimension) Type 2. Pada tabel dim_account, ditambahkan kolom valid_from, valid_to, dan is_current untuk merepresentasikan versi historis akun. Jika ditemukan perubahan pada akun (misalnya perubahan nama, kode, atau mata uang), maka versi lama akan dinonaktifkan (is_current = 0) dan valid_to akan diisi dengan tanggal perubahan. Selanjutnya, versi baru dari akun tersebut akan dimasukkan dengan status aktif (is_current = 1) dan valid_from diisi dengan tanggal perubahan.

Di sisi lain, tabel fact_balance_sheet menyimpan data saldo akun berdasarkan tanggal laporan (date_report). Untuk memastikan bahwa setiap catatan saldo dapat ditautkan ke versi akun yang tepat, ditambahkan kolom dim_account_id sebagai foreign key yang mengacu pada kolom id di tabel dim_account. Langkah ini sangat penting karena meskipun account_id bersifat tetap, perubahan data akun dapat menyebabkan beberapa versi berbeda dengan account_id yang sama. Tanpa penggunaan dim_account_id, proses join atau pelaporan dapat menghasilkan data duplikat atau tidak akurat.

Dengan pendekatan ini, seluruh catatan saldo yang tersimpan dalam fact_balance_sheet dapat direlasikan secara historis dengan versi akun yang aktif saat data tersebut dicatat. Hal ini memungkinkan visualisasi histori saldo per akun yang valid dan mendukung pelaporan yang akurat.

VISUALISASI

Di project ini menggunakan tools Power BI untuk visualisasikan data yang sudah di olah dan ada 3 hal yang akan divisualisasikan yaitu Saldo Terbaru per Akun, Histori Perubahan Akun dan Histori Saldo per Akun. 

Saldo Terbaru per Akun

Visualisasi pertama dibuat untuk menampilkan nilai saldo terbaru dari setiap akun yang masih aktif. Data yang digunakan berasal dari tabel fact_balance_sheet, kemudian digabungkan dengan dim_account menggunakan relasi foreign key dim_account_id → dim_account.id.
Dalam visualisasi ini, hanya akun yang memiliki is_current = 1 (artinya versi akun aktif) yang ditampilkan. Tujuannya adalah untuk mencerminkan kondisi keuangan perusahaan berdasarkan versi akun terbaru, sesuai dengan permintaan manajemen. Setiap bar dalam grafik menunjukkan nilai saldo terakhir berdasarkan tanggal paling baru dari masing-masing akun, dan ditampilkan dalam bentuk bar chart agar mudah dianalisis secara perbandingan.
filter ditambahkan untuk menyaring akun-akun berdasarkan mata uang (currency).

Histori Perubahan Akun
Visualisasi kedua dibuat untuk menunjukkan histori perubahan akun, khususnya ketika terjadi perubahan nama, kode, atau atribut lainnya akibat proses SCD Type 2.
Visual ini menggunakan data dari tabel dim_account, dan menampilkan seluruh versi akun, baik yang masih aktif (is_current = 1) maupun yang sudah tidak aktif (is_current = 0). Tabel visual ini menyajikan account_id, name, valid_from, valid_to, dan status is_current.
Filter dengan nilai is_current = 0 juga ditambahkan untuk memudahkan pengguna dalam menampilkan hanya baris-baris versi akun lama (historis), sehingga pengguna dapat fokus menganalisis perubahan yang pernah terjadi. 

Histori Saldo per Akun

Visualisasi ketiga bertujuan untuk menampilkan perubahan nilai saldo setiap akun dari waktu ke waktu. Data yang digunakan adalah hasil penggabungan antara fact_balance_sheet dan dim_account, di mana dim_account.name digunakan sebagai identitas akun untuk ditampilkan sebagai series atau legend dalam line chart.
Sumbu X mewakili waktu (date_report), sedangkan sumbu Y menampilkan nilai saldo (value). Dengan format ini, pengguna dapat melihat tren naik-turun saldo per akun secara historis. Jika terjadi perubahan versi akun, maka nama akun yang ditampilkan akan mengikuti versi terbaru yang berlaku pada saat saldo tersebut dicatat, karena penautan sudah dilakukan melalui dim_account_id. Walaupun tidak ditulis dalam bentuk query SQL eksplisit, visual ini merepresentasikan hasil dari query saldo terbaru per akun sesuai kebutuhan task.
