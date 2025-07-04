from django import forms
from django.db import models
from modelcluster.fields import ParentalKey, ParentalManyToManyField
from modelcluster.contrib.taggit import ClusterTaggableManager
from taggit.models import TaggedItemBase
from wagtail.models import Page, Orderable
from wagtail.fields import RichTextField
from wagtail.admin.panels import FieldPanel, InlinePanel, MultiFieldPanel
from wagtail.search import index
from wagtail.snippets.models import register_snippet
from wagtailmarkdown.fields import MarkdownField


class BlogIndexPage(Page):
    EDITOR_CHOICES = [
        ('richtext', 'Rich Text'),
        ('markdown', 'Markdown'),
    ]
    editor_type = models.CharField(
        max_length=10,
        choices=EDITOR_CHOICES,
        default='richtext',
        help_text="Choose which editor to use for the intro."
    )
    intro_richtext = RichTextField(blank=True)
    intro_markdown = MarkdownField(blank=True)

    def get_context(self, request):
        context = super().get_context(request)
        blogpages = self.get_children().live().order_by('-first_published_at')
        context['blogpages'] = blogpages
        return context

    content_panels = Page.content_panels + [
        MultiFieldPanel([
            FieldPanel('editor_type'),
            FieldPanel('intro_richtext'),
            FieldPanel('intro_markdown'),
        ], heading="Intro Content"),
    ]


class BlogPageTag(TaggedItemBase):
    content_object = ParentalKey(
        'BlogPage',
        related_name='tagged_items',
        on_delete=models.CASCADE
    )


class BlogPage(Page):
    EDITOR_CHOICES = [
        ('richtext', 'Rich Text'),
        ('markdown', 'Markdown'),
    ]
    editor_type = models.CharField(
        max_length=10,
        choices=EDITOR_CHOICES,
        default='richtext',
        help_text="Choose which editor to use for the body."
    )
    date = models.DateField("Post date")
    intro = models.CharField(max_length=250)
    body_richtext = RichTextField(blank=True)
    body_markdown = MarkdownField(blank=True)
    authors = ParentalManyToManyField('blog.Author', blank=True)
    tags = ClusterTaggableManager(through=BlogPageTag, blank=True)

    def main_image(self):
        gallery_item = self.gallery_images.first()
        if gallery_item:
            return gallery_item.image
        else:
            return None

    search_fields = Page.search_fields + [
        index.SearchField('intro'),
        index.SearchField('body_richtext'),
        index.SearchField('body_markdown'),
    ]

    content_panels = Page.content_panels + [
        MultiFieldPanel([
            FieldPanel('date'),
            FieldPanel('authors', widget=forms.CheckboxSelectMultiple),
            FieldPanel('tags'),
        ], heading="Blog information"),
        FieldPanel('intro'),
        MultiFieldPanel([
            FieldPanel('editor_type'),
            FieldPanel('body_richtext'),
            FieldPanel('body_markdown'),
        ], heading="Body Content"),
        InlinePanel('gallery_images', label="Gallery images"),
    ]

    @property
    def display_body(self):
        if self.editor_type == 'markdown':
            return self.body_markdown
        return self.body_richtext


class BlogPageGalleryImage(Orderable):
    page = ParentalKey(BlogPage, on_delete=models.CASCADE,
                       related_name='gallery_images')
    image = models.ForeignKey(
        'wagtailimages.Image', on_delete=models.CASCADE, related_name='+'
    )
    caption = models.CharField(blank=True, max_length=250)

    panels = ["image", "caption"]


@register_snippet
class Author(models.Model):
    name = models.CharField(max_length=255)
    author_image = models.ForeignKey(
        'wagtailimages.Image', null=True, blank=True,
        on_delete=models.SET_NULL, related_name='+'
    )

    panels = ["name", "author_image"]

    def __str__(self):
        return self.name

    class Meta:
        verbose_name_plural = 'Authors'


class BlogTagIndexPage(Page):
    def get_context(self, request):
        # Filter by tag
        tag = request.GET.get('tag')
        blogpages = BlogPage.objects.filter(tags__name=tag)
        # Update template context
        context = super().get_context(request)
        context['blogpages'] = blogpages
        return context
