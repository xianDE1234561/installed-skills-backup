---
name: lab-report-from-template
description: Create rich Chinese experiment/lab reports from an experiment guidebook, a Word report template, raw photos, screenshots, and handwritten data. Use when Codex needs to preserve an existing DOCX lab-report template layout while filling experiment purpose/principle, instruments, procedure, data processing, figures, conclusions, error analysis, and thought-question answers.
---

# Lab Report From Template

Use this skill to write course experiment reports from a guidebook plus the user's real photos/data while preserving the provided Word template.

## Core Rules

1. Preserve the user's template. Do not rebuild the page as A4, change page size, margins, cover layout, information fields, borders, or the main body frame unless explicitly asked.
2. Treat the DOCX as a fill-in form. Fill the existing body-table paragraphs and blank lines under each section heading.
3. Use the experiment guidebook as the authority for purpose, principle, equipment, wiring/valve setup, operation steps, report requirements, and thought questions.
4. Use the user's real data first. If data is sparse or partially unreadable, state the assumption in the report and only smooth minimally from adjacent recorded values.
5. Insert original evidence photos and processed plots, but keep them compact. Prefer one composite figure per report over several oversized images.
6. Make the report rich enough to look complete: include principle, detailed procedure, calculation process, trend interpretation, conclusion, error factors, improvements, and thought-question answers.
7. Validate the DOCX structurally and with Word/LibreOffice when available. At minimum, confirm page settings match the template and Word can open the file.

## Workflow

1. Inspect the workspace:
   - Locate the experiment guidebook (`.doc`, `.docx`, `.pdf`), report template (`.docx`), image/data folder, and any existing outputs.
   - For old `.doc` guidebooks, use Word COM or another reliable converter to extract text; do not guess the experiment content.
2. Understand the guidebook:
   - Identify each experiment name.
   - Extract each experiment's purpose, equipment, principle, procedure, data-record requirements, and thought questions.
3. Classify user images:
   - Separate handwritten data sheets, instrument screenshots, trend curves, and equipment photos.
   - Assign each image to the correct experiment based on visible labels and variables.
4. Build report content:
   - Draft section text for the five standard template sections.
   - Expand content from the guidebook, not generic filler.
   - Include calculations from real data and concise interpretations of trends.
5. Fill the template:
   - Use `scripts/fill_template_reports.py` when the template has the same five-section body frame as the bundled template.
   - Copy `assets/original_report_template.docx` as a starting template when the user has no template.
   - If the user supplies another template, use that template path instead.
6. Validate:
   - Check body text length, embedded image count, and page dimensions against the source template.
   - Open with Word COM or render with the Documents skill if available.

## Bundled Resources

- `assets/original_report_template.docx`: the original experiment report template captured from this task.
- `scripts/fill_template_reports.py`: deterministic filler for DOCX templates with a single body table containing the five standard sections.
- `references/report-workflow.md`: detailed content and validation constraints from the successful workflow.

## Script Use

Create a JSON config and run:

```powershell
$py = "C:\Users\USER\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
& $py "<skill-dir>\scripts\fill_template_reports.py" `
  --config ".\reports_config.json" `
  --template "<skill-dir>\assets\original_report_template.docx" `
  --out ".\已完成报告"
```

Config shape:

```json
{
  "reports": [
    {
      "filename": "实验一_报告.docx",
      "experiment_name": "实验名称",
      "sections": {
        "purpose": ["目的、原理内容，每条一段"],
        "devices": ["仪器设备内容"],
        "plan": ["实验方案及实现内容"],
        "data": ["数据记录、计算和处理内容"],
        "conclusion": ["结论、误差分析、改进和思考题回答"]
      },
      "figures": [
        {"label": "原始记录", "path": "图片/record.jpg"},
        {"label": "处理曲线", "path": "生成图表/chart.jpg"},
        {"label": "实时趋势", "path": "图片/trend.jpg"}
      ]
    }
  ]
}
```

Keep each item concise enough to fit in the template slots. For richer reports, use most available slots rather than adding new layout structures.
