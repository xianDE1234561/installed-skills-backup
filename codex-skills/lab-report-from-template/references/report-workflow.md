# Report Workflow Constraints

## Template Preservation

- The original report template is landscape, approximately 42.01 cm by 29.7 cm, with a cover/information area and a large body frame.
- Preserve page size, margins, information table, frame borders, and existing section headings.
- Do not clear the body frame and rebuild it with arbitrary tables. Fill the pre-existing paragraphs below headings.
- If the report looks squeezed into the cover or images overlap text, first check whether the page size was accidentally changed.

## Content Expectations

Each report should include:

- Experiment name.
- Purpose and principle: guidebook-based purpose plus real theory, not just bullet summaries.
- Instruments/software: device names, sensors, actuators, controller channels, software, PC, cables, and special units.
- Scheme/implementation: preparation, wiring/communication, valve/pump setup, controller mode changes, parameter entry, trend recording, and shutdown sequence.
- Data and processing: raw values, formulas, computed parameters, comparison across parameter groups, trend interpretation, and figure references.
- Conclusion/thought questions: concrete answers, error factors, improvements, and what the result proves.

## Data Handling

- Use the user's handwritten tables and screenshots as the primary data source.
- If a value is hard to read, infer only from neighboring values or the visible trend; phrase it as a small smoothing/reading assumption if needed.
- Use compact figures. Prefer a single composite figure containing original record, processed curve, and trend screenshot.
- Do not make charts with libraries that are not installed. PIL-based simple plots are acceptable; bundled Python usually has `python-docx` and `PIL`.

## Validation Checklist

Before final delivery:

- Confirm each output `.docx` can be opened by `python-docx`.
- Confirm the output page width/height and margins match the source template.
- Confirm the body frame still has the expected five sections.
- Confirm all reports include images and key real data values.
- Use Word COM to open and compute page counts if available.
- If LibreOffice/soffice is available, use the Documents skill renderer for PNG visual QA.

## Common Failure Modes

- Recreating the document as ordinary A4 portrait output.
- Inserting many full-size screenshots, causing layout overlap.
- Writing only a few summary bullets instead of filling the report sections.
- Ignoring the guidebook's experiment-specific report requirements and thought questions.
- Treating handwritten data as decorative images without extracting values.
