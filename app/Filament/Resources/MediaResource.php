<?php

namespace App\Filament\Resources;

use Filament\Forms;
use Filament\Tables;
use App\Models\Media;
use Filament\Forms\Form;
use Filament\Tables\Table;
use Illuminate\Support\Str;
use Filament\Resources\Resource;
use function Laravel\Prompts\text;
use Filament\Forms\Components\Group;
use Filament\Forms\Components\Select;
use Filament\Tables\Columns\TextColumn;
use Filament\Forms\Components\TextInput;
use Filament\Tables\Columns\ImageColumn;
use Filament\Forms\Components\FileUpload;
use Filament\Tables\Filters\SelectFilter;
use Illuminate\Database\Eloquent\Builder;
use App\Filament\Resources\MediaResource\Pages;

use Illuminate\Database\Eloquent\SoftDeletingScope;
use App\Filament\Resources\MediaResource\RelationManagers;
use Livewire\Features\SupportFileUploads\TemporaryUploadedFile;

class MediaResource extends Resource
{
    protected static ?string $model = Media::class;

    protected static ?string $navigationIcon = 'heroicon-o-rectangle-stack';
    protected static ?string $navigationGroup = 'Content Management';

    public static function form(Form $form): Form
    {
        return $form
        ->schema([
            TextInput::make('title')
                ->label('Title')
                ->required()
                ->maxLength(255),
            Select::make('type')
                ->options([
                    'video' => 'Video',
                    'audio' => 'Audio',
                ])
                ->required()
                ->reactive(),

            FileUpload::make('file_path')
                ->label('Upload File')
                ->required()
                ->directory(fn ($get) => $get('type') === 'video' ? 'media/videos' : 'media/musics')
                ->getUploadedFileNameForStorageUsing(
                    fn (TemporaryUploadedFile $file, $get): string =>
                        Str::slug($get('title')) . '.' . $file->guessExtension()
                )
                ->reactive()
                ->visibility('public')
                ->acceptedFileTypes(['video/mp4', 'audio/mpeg', 'audio/mp3']),
            
            FileUpload::make('thumbnail')
                ->label('Thumbnail Poster')
                ->visible(fn ($get) => $get('type') === 'video')
                ->helperText('This One Optional, just in Case the movie poster doesnt accurate to your mean'),
            
            TextInput::make('release_date')
                ->label('Year of Release')
                ->type('number')
                ->visible(fn ($get) => $get('type') === 'video')
                ->helperText('Enter the release year of the movies'),

            TextInput::make('artist')
                ->label('Artist')
                ->visible(fn($get) => $get('type') === 'audio')
                ->helperText('Enter artist for this music for accurate sync'),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
        ->columns([
            TextColumn::make('id')->sortable()->label('#'),

            ImageColumn::make('thumbnail')
                ->circular()
                ->label('Thumbnail')
                ->size(50)
                ->defaultImageUrl(fn ($record) => $record->type === 'audio' ? $record->artist_image : null),

            TextColumn::make('title')
                ->sortable()
                ->searchable()
                ->label('Judul'),

            TextColumn::make('type')
                ->badge()
                ->colors([
                    'video' => 'info',
                    'audio' => 'success',
                ])
                ->label('Tipe'),

            TextColumn::make('category')
                ->sortable()
                ->searchable()
                ->label('Kategori'),

            TextColumn::make('duration')
                ->label('Durasi')
                ->formatStateUsing(function (?int $state) {
                    if (!$state) return '-';
                    return gmdate('i:s', $state);
                }),

            TextColumn::make('artist')
                ->label('Artist')
                ->searchable()
                ->toggleable(isToggledHiddenByDefault: true),

            TextColumn::make('album')
                ->label('Album')
                ->searchable()
                ->toggleable(isToggledHiddenByDefault: true),

            TextColumn::make('rating')
                ->label('Rating')
                ->numeric()
                ->toggleable(isToggledHiddenByDefault: true),

            TextColumn::make('release_date')
                ->label('Rilis')
                ->date()
                ->toggleable(isToggledHiddenByDefault: true),

            TextColumn::make('language')
                ->label('Bahasa')
                ->toggleable(isToggledHiddenByDefault: true),
        ])
        ->filters([
            SelectFilter::make('type')
                ->options([
                    'video' => 'Video',
                    'audio' => 'Audio',
                ]),
        ])
        ->defaultSort('created_at', 'desc')
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
            'index' => Pages\ListMedia::route('/'),
            'create' => Pages\CreateMedia::route('/create'),
            'edit' => Pages\EditMedia::route('/{record}/edit'),
        ];
    }
}
