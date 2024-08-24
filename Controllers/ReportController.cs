using FastReport.Export.PdfSimple;
using FastReport;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;
using Npgsql;
using System.Data;
using System.Numerics;
using FastReport.Export.Html;
using PuppeteerSharp;

namespace PaySlipJson.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ReportController : ControllerBase
    {
        private readonly string _connectionString = "Host=localhost;Username=postgres;Password=kumarandevi;Database=PaySlip";
        [HttpGet]
        [Route("generate")]
        public async Task<IActionResult> GeneratePayslip([FromQuery] int empId)
        {
            // Get JSON data from PostgreSQL
            string jsonData = GetPayslipJsonFromDb(empId);

            // Convert JSON to DataSet using JsonConvert
            var dataSet = JsonConvert.DeserializeObject<DataSet>(jsonData);

            // Load the FastReport template
            var report = new Report();
            string reportPath = Path.Combine(Directory.GetCurrentDirectory(), "Reports", "PaySlipJson.frx");
            report.Load(reportPath);

            // Register the DataSet and enable each DataTable
            report.RegisterData(dataSet, "Data");
            foreach (DataTable table in dataSet.Tables)
            {
                report.GetDataSource(table.TableName).Enabled = true;
            }

            // Prepare the report
            report.Prepare();

            // Export the report to HTML
            var htmlExport = new HTMLExport
            {
                EmbedPictures = true // Ensure images are embedded
            };

            using var htmlStream = new MemoryStream();
            htmlExport.Export(report, htmlStream);

            // Ensure the stream position is reset to the beginning before reading
            htmlStream.Position = 0;

            // Convert the HTML to a string
            string htmlContent;
            using (var reader = new StreamReader(htmlStream))
            {
                htmlContent = await reader.ReadToEndAsync();
            }

            // Setup PuppeteerSharp to convert HTML to PDF
            var browserFetcher = new BrowserFetcher();
            await browserFetcher.DownloadAsync();
            using var browser = await Puppeteer.LaunchAsync(new LaunchOptions { Headless = true });
            using var page = await browser.NewPageAsync();

            // Set HTML content and convert to PDF
            await page.SetContentAsync(htmlContent);
            var pdfStream = await page.PdfStreamAsync();

            // Convert the PDF stream to a memory stream
            using var memoryStream = new MemoryStream();
            await pdfStream.CopyToAsync(memoryStream);

            // Ensure the stream position is reset to the beginning before returning
            memoryStream.Position = 0;

            // Return the PDF file as a stream
            return File(memoryStream.ToArray(), "application/pdf", "SalarySlip.pdf");
        }
        private string GetPayslipJsonFromDb(int empId)
        {
            using (var conn = new NpgsqlConnection(_connectionString))
            {
                conn.Open();
                using (var cmd = new NpgsqlCommand("SELECT get_payslip_json(@empId);", conn))
                {
                    cmd.Parameters.AddWithValue("empId", empId);
                    var result = cmd.ExecuteScalar();
                    return result.ToString();
                }
            }

        }

    }
}
