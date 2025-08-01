<?php

namespace App\Filament\Resources;

use Filament\Forms;
use Filament\Tables;
use Filament\Forms\Form;
use Filament\Tables\Table;
use App\Models\NewsArticle;
use Filament\Resources\Resource;
use App\Services\PdfNewsExtractor;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Tables\Columns\TextColumn;
use Filament\Forms\Components\TextInput;
use Filament\Tables\Columns\ImageColumn;
use Filament\Forms\Components\FileUpload;
use Illuminate\Database\Eloquent\Builder;
use Filament\Forms\Components\DateTimePicker;
use Illuminate\Database\Eloquent\SoftDeletingScope;
use App\Filament\Resources\NewsArticleResource\Pages;
use App\Filament\Resources\NewsArticleResource\RelationManagers;

class NewsArticleResource extends Resource
{
    protected static ?string $model = NewsArticle::class;

    protected static ?string $navigationIcon = 'heroicon-o-newspaper';

    public static function form(Form $form): Form
    {
        return $form
        ->schema([
            TextInput::make('title')->required(),
            Textarea::make('description'),
            Select::make('category')
                ->options([
                    'sport' => 'Sport',
                    'politic' => 'Politic',
                    'entertainment' => 'Entertainment',
                ]),
            FileUpload::make('image_path')
                ->directory('news_images')
                ->image(),
                FileUpload::make('file_path')
                ->directory('news_files')
                ->afterStateUpdated(function ($state, Forms\Set $set) {
                    if ($state) {
                        $extractor = app(PdfNewsExtractor::class);
                        $result = $extractor->extract('public/news_files/' . $state);

                        $set('title', $result['title']);
                        $set('description', $result['description']);
                        $set('image_path', $result['image_path']);
                    }
                }),
            DateTimePicker::make('published_at')->required(),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('title')->searchable(),
                TextColumn::make('category'),
                ImageColumn::make('image_path'),
                TextColumn::make('published_at')->dateTime(),
            ])
            ->filters([
                //
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListNewsArticles::route('/'),
            'create' => Pages\CreateNewsArticle::route('/create'),
            'edit' => Pages\EditNewsArticle::route('/{record}/edit'),
        ];
    }
}
