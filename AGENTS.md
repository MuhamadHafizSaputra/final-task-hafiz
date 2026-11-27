# AGENTS.md — Pedoman dan Referensi Penulisan Skripsi UGM

> **Panduan resmi:** `@examples/pedoman_ta.pdf`  
> **Contoh Proposal:** `@examples/contoh_proposal.pdf`  
> **Contoh Skripsi:** `@examples/contoh_skripsi.pdf`

---

## Aturan Prioritas (WAJIB DIKUTI)

1. **Pedoman (`pedoman_ta.pdf`) adalah prioritas UTAMA**
2. Jika ada perbedaan antara pedoman dan contoh PDF, **ikuti pedoman**
3. Contoh PDF hanya sebagai referensi format/visual, bukan aturan

---

## Jenis TA: Skripsi Inovasi Produk

Mahasiswa mengembangkan produk/aplikasi/prototipe berbasis teknologi. Proyek ini mengembangkan sistem penimbangan dan pencatatan domba berbasis IoT dengan deteksi bobot stabil. Fokusnya adalah kesinambungan identitas domba setelah penggantian tag RFID dan rekonsiliasi data penimbangan yang terlambat diunggah. Judul dan rincian lingkup dicatat dalam `docs/project-handoff-context.md`.

---

## Struktur PROPOSAL (`proposal/`)

> Class: `\documentclass[proposal,indonesia]{ugmskripsi}`

### Bagian Awal
| Elemen | Ada? | Keterangan |
|--------|------|-----------|
| Halaman Sampul | ✅ | "PROPOSAL TUGAS AKHIR" |
| Halaman Pengesahan | ✅ | Wajib ada, muncul di Daftar Isi |
| Daftar Isi | ✅ | Hanya Daftar Isi |
| Intisari | ✅ | Bahasa Indonesia saja |
| Abstract | ✅ | Contoh memiliki, pedoman tidak menyebut — ikuti contoh |

### Bagian Utama
| Bab | Judul | Isi |
|-----|-------|-----|
| **Bab 1** | Pendahuluan | Latar Belakang, **Rumusan Masalah**, Batasan Masalah, Tujuan Penelitian, Manfaat Penelitian |
| **Bab 2** | Penelitian Terkait | State of the art, literatur review |
| **Bab 3** | Metode dan Rancangan Penelitian | Deskripsi umum, metodologi, bagan alir, perancangan sistem |
| **Bab 4** | Jadwal Penelitian | Gantt Chart berbasis bulan |

### Bagian Akhir
| Elemen | Ada? |
|--------|------|
| Glosarium | ⚠️ Opsional — hanya jika ada jargon teknis yang membingungkan |
| Daftar Pustaka | ✅ |

### Yang TIDAK ADA di Proposal
- ❌ Halaman Pernyataan (Declaration)
- ❌ Motto
- ❌ Persembahan (Acknowledgment)
- ❌ Prakata (Preface)
- ❌ Daftar Tabel
- ❌ Daftar Gambar
- ❌ Daftar Lambang/Simbol
- ❌ Lampiran

---

## Struktur SKRIPSI (`skripsi/`)

> Class: `\documentclass[skripsi,indonesia]{ugmskripsi}`

### Bagian Awal
| Elemen | Ada? | Keterangan |
|--------|------|-----------|
| Halaman Sampul | ✅ | "SKRIPSI" |
| Halaman Pengesahan | ✅ | Muncul di Daftar Isi |
| Halaman Pernyataan | ✅ | Muncul di Daftar Isi |
| Motto | ✅ | Muncul di Daftar Isi |
| Persembahan | ✅ | Muncul di Daftar Isi |
| Prakata | ✅ | Muncul di Daftar Isi |
| Daftar Isi | ✅ | |
| Daftar Tabel | ✅ | |
| Daftar Gambar | ✅ | |
| Daftar Simbol | ✅ | Via `\lambang` |
| Intisari | ✅ | Bahasa Indonesia |
| Abstract | ✅ | Bahasa Inggris |

### Bagian Utama (Inovasi Produk — Bab 3.2 Pedoman)
| Bab | Judul | Isi |
|-----|-------|-----|
| **Bab 1** | Pendahuluan | Latar Belakang, **Perumusan Produk**, Batasan Produk, Tujuan, Manfaat |
| **Bab 2** | Identifikasi Masalah dan Ide Inovatif | Identifikasi masalah nyata + pengembangan ide inovatif |
| **Bab 3** | Kajian Ilmiah | Tinjauan pustaka + dasar ilmiah produk (metode, algoritma, teknologi) |
| **Bab 4** | Perancangan Prototipe/Produk | Arsitektur, UI/UX, database, rancangan teknis |
| **Bab 5** | Proses Pembuatan Produk | Implementasi, kode, integrasi komponen |
| **Bab 6** | Pengujian dan Evaluasi Produk | Metode pengujian, skenario, hasil, evaluasi kinerja + **Kesimpulan dan Saran** |

### Bagian Akhir
| Elemen | Ada? |
|--------|------|
| Daftar Pustaka | ✅ |
| Lampiran | ✅ | Kode, konfigurasi, data primer |

---

## Perbedaan Kunci: Proposal vs Skripsi

| Aspek | Proposal | Skripsi |
|-------|----------|---------|
| Class option | `[proposal]` | `[skripsi]` |
| Cover text | "PROPOSAL TUGAS AKHIR" | "SKRIPSI" |
| Judul Bab 1 | Rumusan **Masalah** | **Perumusan Produk** |
| Bab 2 | Penelitian Terkait | Identifikasi Masalah dan Ide Inovatif |
| Bab 3 | Metode dan Rancangan | Kajian Ilmiah |
| Bab 4 | Jadwal Penelitian | Perancangan Produk |
| Bab 5 | ❌ Tidak ada | Proses Pembuatan Produk |
| Bab 6 | ❌ Tidak ada | Pengujian dan Evaluasi Produk |
| Preliminary pages | Minimal | Lengkap |
| Lampiran | ❌ Tidak ada | ✅ Ada |

---

## Panduan Penulisan Bahasa

- Gunakan **bahasa Indonesia** (`[indonesia]`)
- Bahasa Inggris hanya untuk: judul, abstract, istilah teknis
- Istilah teknis boleh dalam bahasa Inggris dengan penjelasan Indonesia pada pertama kali disebut
- Gunakan Glosarium untuk jargon yang membingungkan

### Gaya Penulisan Proposal

Aturan berikut dirumuskan dari pola penulisan pada `examples/contoh_proposal.pdf`. Pedoman TA tetap menjadi aturan utama jika terdapat perbedaan.

#### Struktur paragraf

- Bangun alur argumentasi dari konteks umum menuju masalah khusus, dampak masalah, pendekatan yang tersedia, keterbatasan pendekatan, lalu posisi penelitian.
- Satu paragraf memuat satu gagasan utama dan biasanya terdiri atas 3--6 kalimat yang saling terhubung.
- Awali paragraf dengan kalimat topik. Lanjutkan dengan penjelasan, bukti atau sitasi, lalu tutup dengan implikasi atau hubungan ke paragraf berikutnya.
- Gunakan transisi eksplisit, seperti `Selain itu`, `Meskipun demikian`, `Sementara itu`, `Dengan demikian`, dan `Berdasarkan hal tersebut`.
- Hindari paragraf yang hanya berisi definisi, daftar teknologi, atau klaim tanpa hubungan dengan masalah penelitian.
- Hubungkan setiap uraian teori atau penelitian terdahulu dengan kebutuhan produk yang diusulkan.

#### Struktur kalimat

- Utamakan kalimat deklaratif yang jelas dengan pola subjek--predikat--objek atau subjek--predikat--keterangan.
- Jaga satu kalimat pada sekitar 15--30 kata jika tidak ada alasan untuk membuatnya lebih panjang.
- Gunakan kalimat majemuk hanya ketika hubungan sebab, akibat, kontras, atau tujuan perlu dinyatakan secara langsung.
- Pecah kalimat yang memuat lebih dari dua gagasan utama.
- Pastikan setiap kata rujukan memiliki antecedent yang jelas; hindari `hal ini`, `tersebut`, atau `yang` tanpa rujukan yang tegas.
- Gunakan kalimat aktif untuk menjelaskan tindakan penelitian. Gunakan kalimat pasif hanya jika pelaku tidak penting.
- Hindari klaim absolut, kata mubazir, pengulangan makna, dan bahasa promosi.
- Bedakan fakta dari rencana: gunakan bentuk lampau atau kini untuk penelitian terdahulu, serta `akan`, `dirancang`, atau `diusulkan` untuk penelitian proposal.

#### Alur penulisan proposal

- `Latar Belakang`: konteks bidang, masalah nyata, bukti atau dampak, pendekatan terdahulu, keterbatasan, dan alasan produk perlu dikembangkan.
- `Rumusan Masalah`: pertanyaan atau pernyataan masalah yang spesifik, terukur, dan dapat dijawab oleh penelitian.
- `Batasan Masalah`: ruang lingkup yang dapat diuji; hindari memasukkan tujuan atau hasil yang belum dijamin.
- `Tujuan Penelitian`: gunakan verba operasional seperti `merancang`, `mengembangkan`, `menguji`, `mengukur`, dan `mengevaluasi`; setiap tujuan harus menjawab rumusan masalah.
- `Manfaat Penelitian`: pisahkan manfaat akademik dan praktis; jangan menulis manfaat sebagai klaim hasil yang belum dibuktikan.
- `Penelitian Terkait`: kelompokkan literatur berdasarkan tema atau pendekatan, bukan hanya berdasarkan urutan sumber; jelaskan persamaan, perbedaan, keterbatasan, dan posisi penelitian.
- `Metode`: jelaskan urutan tahap, masukan, proses, keluaran, instrumen, dan indikator evaluasi.

#### Istilah, angka, dan sitasi

- Gunakan **catatan pemeliharaan** untuk entri yang disimpan di aplikasi, **riwayat pemeliharaan** untuk kumpulan catatan dari waktu ke waktu, dan **kegiatan pemeliharaan** untuk tindakan peternak, seperti memberi pakan atau obat.

- Definisikan singkatan saat pertama kali digunakan, misalnya `Internet of Things (IoT)`, lalu gunakan bentuk singkat secara konsisten.
- Gunakan format `dkk.` untuk tiga penulis atau lebih dalam narasi berbahasa Indonesia; gunakan `dan` untuk dua penulis.
- Pastikan setiap klaim faktual penting memiliki sitasi yang sesuai. Jangan menambahkan sitasi yang belum tersedia di `references.bib`.
- Pastikan semua sitasi menggunakan kunci BibTeX yang benar. Jangan menulis sitasi naratif seperti `Penulis (Tahun)` tanpa menambahkan entri bibliografi.
- Gunakan koma desimal dalam teks Indonesia, misalnya `7,52 kg` dan `0,848`.
- Gunakan satuan SI dan beri spasi antara angka dan satuan, misalnya `10 kg`, `5 m`, dan `90 permintaan per detik`.
- Tulis rentang dengan tanda hubung en dalam LaTeX, misalnya `5--10`.
- Gunakan `\textit{}` untuk istilah asing yang belum diserap; beri padanan atau penjelasan bahasa Indonesia saat pertama kali muncul.
- Konsisten dalam kapitalisasi nama teknologi, nama produk, nama platform, dan istilah metode.
- Tulis judul tabel dan gambar sebagai deskripsi singkat yang informatif. Setiap tabel atau gambar wajib memiliki `\caption{}` dan `\label{}`.

#### Pemeriksaan sebelum menyelesaikan tulisan

- Periksa alur dari masalah menuju solusi dan pastikan tidak ada lompatan logika.
- Periksa kesesuaian antara latar belakang, rumusan masalah, batasan, tujuan, manfaat, dan metode.
- Periksa setiap angka, nama penulis, tahun, DOI, URL, dan klaim teknis terhadap sumber aslinya.
- Periksa semua sitasi terhadap `references.bib`; kompilasi proposal dengan `pdflatex`, `bibtex`, lalu `pdflatex` dua kali.
- Periksa kesalahan LaTeX: karakter khusus (`%`, `$`, `&`, `_`, `#`), tabel yang terlalu lebar, label yang tidak unik, dan referensi silang yang tidak ditemukan.
- Jangan menganggap contoh proposal bebas kesalahan; gunakan pola strukturnya, tetapi perbaiki tata bahasa, ketepatan istilah, sitasi, dan konsistensi sesuai pedoman.

---

## Pedoman untuk AI Assistant (Kewajiban Model)

### Penandaan revisi naskah

- Setiap kali kalimat atau paragraf yang sudah ada dalam proposal atau skripsi direvisi, pertahankan teks sebelumnya secara utuh dan tampilkan teks penggantinya tepat setelahnya, di lokasi revisi dalam naskah.
- Untuk proposal, gunakan sorotan saja tanpa label versi. Gunakan merah muda muda untuk teks lama dan kuning muda untuk teks baru. Untuk skripsi, pertahankan label sebelum dan sesudah revisi.
- Tandai satuan teks terkecil yang tetap dapat dipahami. Untuk paragraf yang direvisi sebagai satu kesatuan, tampilkan satu pasangan paragraf. Untuk revisi berulang, pertahankan urutan versi dan tandai versi terkini. Untuk penambahan murni, cukup sorot teks baru.
- Gunakan penanda LaTeX yang mendukung pemenggalan baris, istilah bercetak miring, dan sitasi. Setelah kompilasi, pastikan kedua versi tampil terbaca. Pertahankan penandaan sampai pengguna meminta penerimaan revisi atau salinan bersih.

1. **Jangan pernah mengarang sumber (hallucination):** Kutip hanya referensi yang benar-benar ada dalam `references.bib` atau yang telah divalidasi. Beri tahu pengguna jika sumber hanya dibaca pada tingkat abstrak.
2. **Jangan asumsikan keputusan desain sebagai final:** Perlakukan keputusan yang tercantum di bagian "Open decisions" pada `docs/project-handoff-context.md` sebagai opsi yang menunggu konfirmasi.
3. **Tanyakan sebelum membuat pilihan besar:** Mintalah konfirmasi pengguna sebelum mengambil keputusan yang mengubah klaim kebaruan atau cakupan penelitian.
4. **Validasi setiap pernyataan:** Beri label atau peringatan jika sebuah pernyataan teknis melampaui apa yang sebenarnya dilaporkan dalam makalah yang dikutip.
5. **Konteks Proyek:** Gunakan `docs/project-handoff-context.md` sebagai referensi utama untuk judul, latar belakang, cakupan, dan detail teknis proyek ini.

---

## Panduan Diagram dan Flowchart

- **Bagan Alir Metodologi** (Bab 3 Proposal / Bab 3-4 Skripsi): Wajib ada, visualisasi tahapan
- **Arsitektur Sistem** (Bab 3-4): Diagram komponen dan hubungannya
- **ERD / Skema Database** (jika relevan): Diagram relasi entitas
- **UI/UX Wireframe atau Mockup** (jika ada antarmuka): Rancangan tampilan
- **Gantt Chart** (Bab 4 Proposal): Jadwal penelitian berbasis bulan
- Semua diagram menggunakan environment `figure` dengan caption dan label

---

## Referensi Cepat LaTeX

### Citasi
```latex
\citep{key}   % (Author, Year)
\citet{key}   % Author (Year)
```

### Gambar
```latex
\begin{figure}[H]
  \centering
  \includegraphics[width=0.8\textwidth]{figures/nama-file}
  \caption{Deskripsi gambar}
  \label{fig:label}
\end{figure}
```

### Tabel
```latex
\begin{table}[H]
  \centering
  \caption{Judul tabel}
  \begin{tabular}{|l|c|r|}
    \hline
    Kolom 1 & Kolom 2 & Kolom 3 \\
    \hline
    Data & Data & Data \\
    \hline
  \end{tabular}
  \label{tab:label}
\end{table}
```

### Kode / Listing
```latex
\begin{lstlisting}[language=yaml, caption={Judul}]
# kode di sini
\end{lstlisting}
```

---

## Kompilasi

```bash
export PATH="/Library/TeX/texbin:$PATH"
cd proposal/  # atau cd skripsi/
pdflatex main.tex && bibtex main && pdflatex main.tex && pdflatex main.tex
```

---

## Catatan Penting

- Jangan lupa mengisi metadata (nama, NIM, dosen pembimbing, dosen penguji) di `main.tex`
- Ganti `figures/logougm.pdf` dengan logo UGM resmi
- Untuk proposal: fokus pada **perencanaan**, bukan hasil
- Untuk skripsi: setiap bab harus terstruktur dan merujuk ke pedoman
- Gunakan `\bibliography{references}` untuk daftar pustaka
- Pastikan semua `\citep` / `\citet` ada di `references.bib`
