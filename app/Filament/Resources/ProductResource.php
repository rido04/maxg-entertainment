<?php

namespace App\Filament\Resources;

use Filament\Forms;
use Filament\Tables;
use App\Models\Product;
use Filament\Forms\Form;
use Filament\Tables\Table;
use Illuminate\Support\Str;
use Filament\Resources\Resource;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Toggle;
use Filament\Forms\Components\Section;
use Filament\Forms\Components\Textarea;
use Filament\Tables\Actions\EditAction;
use Filament\Tables\Actions\ViewAction;
use Filament\Tables\Columns\TextColumn;
use Filament\Forms\Components\TextInput;
use Filament\Tables\Columns\ImageColumn;
use Filament\Forms\Components\FileUpload;
use Filament\Tables\Actions\DeleteAction;
use Filament\Tables\Filters\SelectFilter;
use Illuminate\Database\Eloquent\Builder;
use Filament\Tables\Columns\BooleanColumn;
use Filament\Tables\Filters\TernaryFilter;
use Filament\Tables\Actions\BulkActionGroup;
use Filament\Tables\Actions\DeleteBulkAction;
use App\Filament\Resources\ProductResource\Pages;
use Illuminate\Database\Eloquent\SoftDeletingScope;
use App\Filament\Resources\ProductResource\RelationManagers;
use Filament\Tables\Columns\ToggleColumn;
use Livewire\Features\SupportFileUploads\TemporaryUploadedFile;

class ProductResource extends Resource
{
    protected static ?string $model = Product::class;

    protected static ?string $navigationIcon = 'heroicon-o-shopping-cart';
    protected static ?string $navigationGroup = 'Content Management';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Section::make('Product Information')
                    ->schema([
                        TextInput::make('name')
                            ->required()
                            ->helperText('Product name must not use dashes (-) or any special characters')
                            ->maxLength(255)
                            ->live(onBlur: true)
                            ->afterStateUpdated(function (string $context, $state, callable $set) {
                                if ($context === 'create') {
                                    $set('sku', strtoupper(str_replace(' ', '-', $state)) . '-' . rand(1000, 9999));
                                }
                            }),

                        Textarea::make('description')
                            ->required()
                            ->rows(4)
                            ->columnSpanFull(),

                        TextInput::make('sku')
                            ->label('SKU')
                            ->required()
                            ->unique(ignoreRecord: true)
                            ->maxLength(255)
                            ->alphaNum()
                            ->suffix('Auto-generated')
                            ->helperText('Unique product identifier'),

                        Select::make('category')
                            ->options([
                                'electronics' => 'Electronics',
                                'clothing' => 'Clothing',
                                'books' => 'Books',
                                'home-garden' => 'Home & Garden',
                                'sports' => 'Sports',
                                'beauty' => 'Beauty & Health',
                                'automotive' => 'Automotive',
                                'toys' => 'Toys & Games',
                                'food' => 'Food & Beverages',
                                'other' => 'Other',
                            ])
                            ->searchable()
                            ->preload()
                            ->placeholder('Select a category'),
                    ])
                    ->columns(2),

                Section::make('Pricing & Inventory')
                    ->schema([
                        TextInput::make('price')
                            ->required()
                            ->numeric()
                            ->prefix('Rp')
                            ->minValue(0)
                            ->step(0.01)
                            ->placeholder('0.00'),

                        TextInput::make('stock')
                            ->required()
                            ->numeric()
                            ->minValue(0)
                            ->default(0)
                            ->suffix('units'),
                    ])
                    ->columns(2),

                Section::make('Media & Status')
                    ->schema([
                        FileUpload::make('image_path')
                            ->image()
                            ->directory('products')
                            ->disk('public')
                            ->imageEditor()
                            ->imageEditorAspectRatios([
                                '16:9',
                                '4:3',
                                '1:1',
                            ])
                            ->getUploadedFileNameForStorageUsing(
                                fn (TemporaryUploadedFile $file): string =>
                                    Str::random(20).'.'.$file->guessExtension())
                            ->maxSize(2048)
                            ->helperText('Max file size: 2MB. Recommended: 800x600px'),

                        Toggle::make('is_active')
                            ->label('Active Status')
                            ->default(true)
                            ->helperText('Inactive products won\'t be visible to customers'),
                    ])
                    ->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                ImageColumn::make('image_path')
                    ->label('Image')
                    ->circular()
                    ->disk('public')
                    ->url(fn ($record) => asset("storage/products/{$record->image_path}"))
                    ->defaultImageUrl(asset('images/default-product.png')),

                TextColumn::make('name')
                    ->searchable()
                    ->sortable()
                    ->weight('bold')
                    ->description(fn (Product $record): string => $record->sku),

                TextColumn::make('category')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'electronics' => 'info',
                        'clothing' => 'warning',
                        'books' => 'success',
                        'home-garden' => 'primary',
                        'sports' => 'danger',
                        'beauty' => 'pink',
                        'automotive' => 'gray',
                        'toys' => 'yellow',
                        'food' => 'green',
                        default => 'secondary',
                    })
                    ->sortable(),

                TextColumn::make('price')
                    ->money('IDR')
                    ->sortable()
                    ->alignEnd(),

                TextColumn::make('stock')
                    ->sortable()
                    ->badge()
                    ->color(fn (int $state): string => match (true) {
                        $state === 0 => 'danger',
                        $state < 10 => 'warning',
                        default => 'success',
                    })
                    ->formatStateUsing(fn (int $state): string => $state . ' units')
                    ->alignCenter(),

                ToggleColumn::make('is_active')
                    ->label('Active')
                    ->sortable(),

                TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),

                TextColumn::make('updated_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                SelectFilter::make('category')
                    ->options([
                        'electronics' => 'Electronics',
                        'clothing' => 'Clothing',
                        'books' => 'Books',
                        'home-garden' => 'Home & Garden',
                        'sports' => 'Sports',
                        'beauty' => 'Beauty & Health',
                        'automotive' => 'Automotive',
                        'toys' => 'Toys & Games',
                        'food' => 'Food & Beverages',
                        'other' => 'Other',
                    ])
                    ->multiple(),

                TernaryFilter::make('is_active')
                    ->label('Status')
                    ->placeholder('All products')
                    ->trueLabel('Active only')
                    ->falseLabel('Inactive only'),

                Tables\Filters\Filter::make('low_stock')
                    ->label('Low Stock')
                    ->query(fn ($query) => $query->where('stock', '<', 10))
                    ->toggle(),

                Tables\Filters\Filter::make('out_of_stock')
                    ->label('Out of Stock')
                    ->query(fn ($query) => $query->where('stock', '=', 0))
                    ->toggle(),
            ])
            ->actions([
                ViewAction::make(),
                EditAction::make(),
                DeleteAction::make(),
            ])
            ->bulkActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),

                    Tables\Actions\BulkAction::make('activate')
                        ->label('Activate Selected')
                        ->icon('heroicon-o-check-circle')
                        ->color('success')
                        ->action(function ($records) {
                            $records->each->update(['is_active' => true]);
                        })
                        ->deselectRecordsAfterCompletion(),

                    Tables\Actions\BulkAction::make('deactivate')
                        ->label('Deactivate Selected')
                        ->icon('heroicon-o-x-circle')
                        ->color('danger')
                        ->action(function ($records) {
                            $records->each->update(['is_active' => false]);
                        })
                        ->deselectRecordsAfterCompletion(),
                ]),
            ])
            ->defaultSort('created_at', 'desc')
            ->emptyStateActions([
                Tables\Actions\CreateAction::make()
                    ->label('Create your first product')
                    ->icon('heroicon-o-plus'),
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
            'index' => Pages\ListProducts::route('/'),
            'create' => Pages\CreateProduct::route('/create'),
            'edit' => Pages\EditProduct::route('/{record}/edit'),
        ];
    }
}
