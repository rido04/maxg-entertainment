<?php

namespace App\Filament\Resources;

use Filament\Forms;
use Filament\Tables;
use Filament\Forms\Form;
use Filament\Tables\Table;
use App\Models\Advertisement;
use Filament\Resources\Resource;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Toggle;
use Filament\Tables\Columns\TextColumn;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\FileUpload;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;
use App\Filament\Resources\AdvertisementResource\Pages;
use App\Filament\Resources\AdvertisementResource\RelationManagers;
use Filament\Tables\Columns\ToggleColumn;

class AdvertisementResource extends Resource
{
    protected static ?string $model = Advertisement::class;
    protected static ?string $navigationIcon = 'heroicon-o-play';
    protected static ?string $navigationGroup = 'Media Management';

    public static function form(Forms\Form $form): Forms\Form
    {
        return $form
            ->schema([
                TextInput::make('title')
                    ->required()
                    ->maxLength(255),
                FileUpload::make('video_path')
                    ->label('Advertisement Video')
                    ->directory('media/ads')
                    ->acceptedFileTypes(['video/mp4', 'video/avi', 'video/mov'])
                    ->required(),
                TextInput::make('duration')
                    ->label('Duration (seconds)')
                    ->numeric()
                    ->required(),
                Select::make('target_category')
                    ->label('Target Category')
                    ->options([
                        'all' => 'All Categories',
                        'Action' => 'Action',
                        'Comedy' => 'Comedy',
                        'Drama' => 'Drama',
                        'Horror' => 'Horror',
                        'Romance' => 'Romance'
                    ])
                    ->default('all'),
                Toggle::make('is_active')
                    ->label('Active')
                    ->default(true),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('title')
                    ->sortable()
                    ->searchable(),
                TextColumn::make('target_category')
                    ->label('Target Category')
                    ->sortable()
                    ->searchable(),
                TextColumn::make('duration')
                    ->label('Duration (seconds)')
                    ->sortable(),
                ToggleColumn::make('is_active')
                    ->label('Active')
                    ->sortable(),
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
            'index' => Pages\ListAdvertisements::route('/'),
            'create' => Pages\CreateAdvertisement::route('/create'),
            'edit' => Pages\EditAdvertisement::route('/{record}/edit'),
        ];
    }
}
