from django.db import models
from wagtail.models import Page
from wagtail.fields import RichTextField
from wagtail.admin.panels import FieldPanel, MultiFieldPanel
from wagtailmarkdown.fields import MarkdownField


class HomePage(Page):
    EDITOR_CHOICES = [
        ('richtext', 'Rich Text'),
        ('markdown', 'Markdown'),
    ]
    editor_type = models.CharField(
        max_length=10,
        choices=EDITOR_CHOICES,
        default='richtext',
        help_text="Choose which editor to use for the main content."
    )
    body_richtext = RichTextField(blank=True)
    body_markdown = MarkdownField(blank=True)

    content_panels = Page.content_panels + [
        MultiFieldPanel([
            FieldPanel('editor_type'),
            FieldPanel('body_richtext'),
            FieldPanel('body_markdown'),
        ], heading="Content"),
    ]

    @property
    def display_body(self):
        if self.editor_type == 'markdown':
            return self.body_markdown
        return self.body_richtext
